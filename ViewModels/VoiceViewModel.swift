import Foundation
import SwiftUI
import AVFoundation

// MARK: - Advanced Voice Mode State & Session Coordinator

public enum VoiceSessionState: String, Sendable {
    case disconnected
    case connecting
    case listening
    case thinking
    case speaking
}

@MainActor
@Observable
public final class VoiceViewModel: NSObject {
    public var state: VoiceSessionState = .disconnected
    public var selectedVoice: VoicePreset = .juniper
    public var audioPower: Float = 0.0 // 0.0 to 1.0 normalized
    public var isMuted: Bool = false
    public var conversationId: String?
    public var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var powerTimer: Timer?
    private let networkClient: OpenAINetworkClient

    public init(conversationId: String? = nil, networkClient: OpenAINetworkClient = .shared) {
        self.conversationId = conversationId
        self.networkClient = networkClient
        self.selectedVoice = AppSettings.shared.voicePreset
        super.init()
    }

    public func startSession() async {
        guard state == .disconnected else { return }
        state = .connecting
        errorMessage = nil

        do {
            try configureAudioSession()

            // Fetch realtime session token from backend
            let response: VoiceSessionConfig = try await networkClient.execute(
                .createVoiceSession(conversationId: conversationId, voice: selectedVoice)
            )

            // Connect to LiveKit WebRTC server
            try await establishWebRTCTransport(serverUrl: response.serverUrl, token: response.token)

            startAudioMetering()
            state = .listening
        } catch {
            state = .disconnected
            errorMessage = error.localizedDescription
        }
    }

    public func endSession() {
        stopAudioMetering()
        audioRecorder?.stop()
        audioRecorder = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        state = .disconnected
        audioPower = 0.0
    }

    public func toggleMute() {
        isMuted.toggle()
        if isMuted {
            audioPower = 0.0
        }
    }

    // MARK: - Audio Session & Metering Pipeline

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
        try session.setActive(true)
    }

    private func establishWebRTCTransport(serverUrl: String, token: String) async throws {
        // Simulates connection handshake with LiveKit gateway
        try await Task.sleep(nanoseconds: 600_000_000)
    }

    private func startAudioMetering() {
        let dummyURL = FileManager.default.temporaryDirectory.appendingPathComponent("metering_dummy.caf")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]

        guard let recorder = try? AVAudioRecorder(url: dummyURL, settings: settings) else { return }
        recorder.isMeteringEnabled = true
        recorder.record()
        self.audioRecorder = recorder

        powerTimer?.invalidate()
        powerTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, !self.isMuted, let rec = self.audioRecorder else { return }
            rec.updateMeters()
            let power = rec.averagePower(forChannel: 0) // -160 dB to 0 dB
            let normalized = max(0.0, min(1.0, (power + 50.0) / 50.0))
            self.audioPower = normalized

            // State simulation based on audio threshold
            if self.state == .listening && normalized > 0.4 {
                // User speaking
            }
        }
    }

    private func stopAudioMetering() {
        powerTimer?.invalidate()
        powerTimer = nil
    }
}
