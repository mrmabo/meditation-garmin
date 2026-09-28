import Foundation

// Integration seam for Garmin's official Connect IQ Mobile SDK.
//
// Keep this file dependency-free until the SDK is added to the Xcode target.
// Once installed:
// 1. import ConnectIQ
// 2. initialize the SDK with the app URL scheme
// 3. discover/select the user's Garmin device
// 4. create an IQApp for the companion watch app UUID
// 5. encode the commands below into Connect IQ-compatible values
// 6. send them with the SDK's app-message API
//
// The watch must own the meditation timer after receiving "start". That makes
// the reminder resilient to iOS suspension and temporary Bluetooth disconnects.

enum GarminCommand {
    static func start(_ session: MeditationSession) -> [String: Any] {
        [
            "type": "start",
            "sessionId": session.id.uuidString,
            "durationSeconds": Int(session.duration),
            "pattern": session.pattern.rawValue,
            "startedAt": Int(session.startedAt.timeIntervalSince1970)
        ]
    }

    static func pause(_ id: UUID) -> [String: Any] {
        ["type": "pause", "sessionId": id.uuidString]
    }

    static func resume(_ session: MeditationSession) -> [String: Any] {
        [
            "type": "resume",
            "sessionId": session.id.uuidString,
            "remainingSeconds": max(Int(session.endAt.timeIntervalSinceNow), 0)
        ]
    }

    static func stop(_ id: UUID) -> [String: Any] {
        ["type": "stop", "sessionId": id.uuidString]
    }
}
