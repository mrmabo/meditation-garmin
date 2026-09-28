import SwiftUI

@main
struct MeditationGarminApp: App {
    @StateObject private var viewModel = MeditationViewModel()

    var body: some Scene {
        WindowGroup {
            MeditationView(viewModel: viewModel)
        }
    }
}
