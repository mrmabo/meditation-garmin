import UIKit

@MainActor
final class ReminderService {
    private let generator = UINotificationFeedbackGenerator()

    func prepare() {
        generator.prepare()
    }

    func play(_ pattern: ReminderPattern) async {
        switch pattern {
        case .gentle:
            generator.notificationOccurred(.success)
        case .double:
            generator.notificationOccurred(.success)
            try? await Task.sleep(for: .seconds(2))
            generator.notificationOccurred(.success)
        case .progressive:
            generator.notificationOccurred(.success)
            try? await Task.sleep(for: .seconds(3))
            generator.notificationOccurred(.success)
            try? await Task.sleep(for: .seconds(2))
            generator.notificationOccurred(.success)
        }
    }
}
