import Foundation

// MARK: - Voice Mode & Real-time LiveKit Contracts

public enum VoicePreset: String, Codable, CaseIterable, Sendable, Identifiable {
    case breeze = "breeze"
    case cove = "cove"
    case ember = "ember"
    case juniper = "juniper"
    case maple = "maple"
    case sol = "sol"
    case spruce = "spruce"
    case vale = "vale"

    public var id: String { rawValue }

    public var displayName: String {
        rawValue.capitalized
    }

    public var description: String {
        switch self {
        case .breeze: return "Calm, animated, and friendly"
        case .cove: return "Measured, candid, and direct"
        case .ember: return "Confident, optimistic, and warm"
        case .juniper: return "Open, upbeat, and thoughtful"
        case .maple: return "Cheerful, easygoing, and energetic"
        case .sol: return "Savvy, relaxed, and knowledgeable"
        case .spruce: return "Composed, grounding, and articulate"
        case .vale: return "Bright, inquisitive, and supportive"
        }
    }
}

public struct VoiceSessionConfig: Codable, Sendable {
    public let serverUrl: String
    public let token: String
    public let conversationId: String?
    public let voice: VoicePreset

    public enum CodingKeys: String, CodingKey {
        case serverUrl = "server_url"
        case token
        case conversationId = "conversation_id"
        case voice
    }

    public init(serverUrl: String, token: String, conversationId: String? = nil, voice: VoicePreset = .juniper) {
        self.serverUrl = serverUrl
        self.token = token
        self.conversationId = conversationId
        self.voice = voice
    }
}
