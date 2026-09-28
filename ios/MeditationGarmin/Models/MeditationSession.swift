import Foundation

enum ReminderPattern: String, CaseIterable, Identifiable, Codable {
    case gentle
    case double
    case progressive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: "Gentle"
        case .double: "Double"
        case .progressive: "Progressive"
        }
    }

    var subtitle: String {
        switch self {
        case .gentle: "One soft cue"
        case .double: "Two soft cues"
        case .progressive: "Three gradually spaced cues"
        }
    }
}

enum SessionState: Equatable {
    case idle
    case running
    case paused
    case completed
}

struct MeditationSession: Identifiable {
    let id: UUID
    let duration: TimeInterval
    let pattern: ReminderPattern
    let startedAt: Date
    var endAt: Date
    var pausedRemaining: TimeInterval?

    init(duration: TimeInterval, pattern: ReminderPattern, now: Date = .now) {
        self.id = UUID()
        self.duration = duration
        self.pattern = pattern
        self.startedAt = now
        self.endAt = now.addingTimeInterval(duration)
    }
}
