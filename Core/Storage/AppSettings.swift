import Foundation
import SwiftUI

// MARK: - App Preferences & Local Storage Settings

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()

    @AppStorage("openai_selected_model_slug")
    public var selectedModelSlug: String = "gpt-4o"

    @AppStorage("openai_selected_voice")
    public var selectedVoice: String = VoicePreset.juniper.rawValue

    @AppStorage("openai_haptic_feedback_enabled")
    public var isHapticsEnabled: Bool = true

    @AppStorage("openai_history_and_training_enabled")
    public var isHistoryAndTrainingEnabled: Bool = true

    @AppStorage("openai_color_scheme_preference")
    public var colorSchemePreference: String = "system" // system, light, dark

    @AppStorage("openai_speech_rate")
    public var speechRate: Double = 1.0

    @AppStorage("openai_developer_mode_enabled")
    public var isDeveloperModeEnabled: Bool = false

    private init() {}

    public var voicePreset: VoicePreset {
        get { VoicePreset(rawValue: selectedVoice) ?? .juniper }
        set { selectedVoice = newValue.rawValue }
    }
}
