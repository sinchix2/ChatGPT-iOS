import Foundation

// MARK: - Server-Sent Events (SSE) Contracts

public struct SSEvent: Sendable, Equatable {
    public let event: String?
    public let data: String
    public let id: String?
    public let retry: Int?

    public init(event: String? = nil, data: String, id: String? = nil, retry: Int? = nil) {
        self.event = event
        self.data = data
        self.id = id
        self.retry = retry
    }

    public var isDone: Bool {
        data.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]"
    }
}

public struct ConversationStreamChunk: Codable, Sendable {
    public let message: MessagePayload?
    public let conversationId: String?
    public let error: String?

    public enum CodingKeys: String, CodingKey {
        case message
        case conversationId = "conversation_id"
        case error
    }
}
