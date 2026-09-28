import SwiftUI

struct MeditationView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        header
                        timer
                        controls
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Meditate")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refreshAfterForeground()
            }
        }
    }

    private var header: some View {
        HStack {
            Label(
                viewModel.garminConnected ? "Watch connected" : "iPhone mode",
                systemImage: viewModel.garminConnected ? "applewatch.radiowaves.left.and.right" : "iphone"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var timer: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(.primary.opacity(0.7), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 6) {
                    Text(viewModel.timeText)
                        .font(.system(size: 54, weight: .light, design: .rounded))
                        .monospacedDigit()
                    Text(stateLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 250, height: 250)

            if viewModel.state == .idle || viewModel.state == .completed {
                durationPicker
                patternPicker
            }

            if let message = viewModel.statusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Duration").font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.presets, id: \.self) { minutes in
                        Button("\(minutes) min") {
                            viewModel.select(minutes: minutes)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(viewModel.selectedMinutes == minutes ? .primary : .secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var patternPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ending reminder").font(.headline)
            ForEach(ReminderPattern.allCases) { pattern in
                Button {
                    viewModel.selectedPattern = pattern
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: viewModel.selectedPattern == pattern ? "checkmark.circle.fill" : "circle")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pattern.title)
                                .foregroundStyle(.primary)
                            Text(pattern.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var controls: some View {
        switch viewModel.state {
        case .idle:
            primaryButton("Start Meditation", icon: "play.fill") { viewModel.start() }
        case .running:
            HStack {
                Button("End", role: .destructive) { viewModel.stop() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Pause", systemImage: "pause.fill") { viewModel.pause() }
                    .buttonStyle(.borderedProminent)
            }
        case .paused:
            HStack {
                Button("End", role: .destructive) { viewModel.stop() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Resume", systemImage: "play.fill") { viewModel.resume() }
                    .buttonStyle(.borderedProminent)
            }
        case .completed:
            primaryButton("Done", icon: "checkmark") { viewModel.reset() }
        }
    }

    private func primaryButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var stateLabel: String {
        switch viewModel.state {
        case .idle: "Ready"
        case .running: "Breathe"
        case .paused: "Paused"
        case .completed: "Complete"
        }
    }
}
