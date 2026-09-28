import Foundation

protocol GarminBridge {
    var isConnected: Bool { get }
    func start(session: MeditationSession) async throws
    func pause(sessionID: UUID) async throws
    func resume(session: MeditationSession) async throws
    func stop(sessionID: UUID) async throws
}

struct MockGarminBridge: GarminBridge {
    var isConnected: Bool { false }

    func start(session: MeditationSession) async throws {}
    func pause(sessionID: UUID) async throws {}
    func resume(session: MeditationSession) async throws {}
    func stop(sessionID: UUID) async throws {}
}
