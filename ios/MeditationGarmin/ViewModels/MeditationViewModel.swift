import Foundation

@MainActor
final class MeditationViewModel: ObservableObject {
    @Published var selectedMinutes = 20
    @Published var selectedPattern: ReminderPattern = .progressive
    @Published private(set) var state: SessionState = .idle
    @Published private(set) var session: MeditationSession?
    @Published private(set) var remaining: TimeInterval = 20 * 60
    @Published private(set) var statusMessage: String?

    let presets = [5, 10, 15, 20, 30, 45, 60]

    private let garmin: GarminBridge
    private let reminder = ReminderService()
    private var ticker: Task<Void, Never>?

    init(garmin: GarminBridge = MockGarminBridge()) {
        self.garmin = garmin
    }

    var garminConnected: Bool { garmin.isConnected }

    var progress: Double {
        guard let session, session.duration > 0 else { return 0 }
        return min(max(1 - remaining / session.duration, 0), 1)
    }

    var timeText: String {
        let seconds = max(Int(remaining.rounded(.up)), 0)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    func select(minutes: Int) {
        guard state == .idle || state == .completed else { return }
        selectedMinutes = minutes
        remaining = TimeInterval(minutes * 60)
    }

    func start() {
        ticker?.cancel()
        let newSession = MeditationSession(
            duration: TimeInterval(selectedMinutes * 60),
            pattern: selectedPattern
        )
        session = newSession
        remaining = newSession.duration
        state = .running
        statusMessage = nil
        reminder.prepare()

        Task {
            do {
                try await garmin.start(session: newSession)
            } catch {
                statusMessage = "Garmin unavailable — iPhone reminder remains active."
            }
        }
        runTicker()
    }

    func pause() {
        guard state == .running, var current = session else { return }
        updateRemaining()
        current.pausedRemaining = remaining
        session = current
        state = .paused
        ticker?.cancel()

        Task { try? await garmin.pause(sessionID: current.id) }
    }

    func resume() {
        guard state == .paused, var current = session else { return }
        let value = current.pausedRemaining ?? remaining
        current.endAt = .now.addingTimeInterval(value)
        current.pausedRemaining = nil
        session = current
        state = .running

        Task { try? await garmin.resume(session: current) }
        runTicker()
    }

    func stop() {
        let id = session?.id
        ticker?.cancel()
        session = nil
        state = .idle
        remaining = TimeInterval(selectedMinutes * 60)

        if let id {
            Task { try? await garmin.stop(sessionID: id) }
        }
    }

    func reset() {
        ticker?.cancel()
        session = nil
        state = .idle
        remaining = TimeInterval(selectedMinutes * 60)
        statusMessage = nil
    }

    func refreshAfterForeground() {
        guard state == .running else { return }
        updateRemaining()
        if remaining <= 0 { complete() }
    }

    private func runTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                self?.updateRemaining()
                if let self, self.remaining <= 0 {
                    self.complete()
                    return
                }
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    private func updateRemaining() {
        guard state == .running, let session else { return }
        remaining = max(session.endAt.timeIntervalSinceNow, 0)
    }

    private func complete() {
        guard state == .running else { return }
        ticker?.cancel()
        remaining = 0
        state = .completed
        let pattern = session?.pattern ?? selectedPattern
        Task { await reminder.play(pattern) }
    }
}
