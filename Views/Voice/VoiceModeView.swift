import SwiftUI

// MARK: - Advanced Voice Mode Fullscreen View

public struct VoiceModeView: View {
    @State private var viewModel: VoiceViewModel
    @Environment(\.dismiss) private var dismiss

    public init(conversationId: String? = nil) {
        _viewModel = State(initialValue: VoiceViewModel(conversationId: conversationId))
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // Top Bar
                HStack {
                    Button {
                        viewModel.endSession()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.title3.bold())
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(12)
                    }

                    Spacer()

                    Text(viewModel.selectedVoice.displayName)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    Button {
                        // Options menu
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3.bold())
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                // Fluid Horizon Audio Orb Visualizer
                VStack(spacing: 24) {
                    HorizonAudioVisualizerView(
                        audioPower: viewModel.audioPower,
                        state: viewModel.state
                    )

                    Text(statusText)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .animation(.easeInOut, value: viewModel.state)
                }

                Spacer()

                // Bottom Controls Bar
                HStack(spacing: 40) {
                    // Camera Vision Button
                    Button {
                        // Vision frame capture
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    // Mic Mute Button
                    Button {
                        viewModel.toggleMute()
                    } label: {
                        Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(viewModel.isMuted ? Color.red.opacity(0.8) : Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    // End Session Button
                    Button {
                        viewModel.endSession()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.startSession()
        }
    }

    private var statusText: String {
        switch viewModel.state {
        case .disconnected: return "Connecting..."
        case .connecting: return "Connecting..."
        case .listening: return viewModel.isMuted ? "Muted" : "Listening..."
        case .thinking: return "Thinking..."
        case .speaking: return "Speaking..."
        }
    }
}
