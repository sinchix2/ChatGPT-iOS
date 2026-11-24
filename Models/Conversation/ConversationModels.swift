import Foundation

// MARK: - Conversation Request & Response Contracts

public struct ConversationRequest: Encodable, Sendable {
    public let action: String
    public let messages: [MessagePayload]
    public let parentMessageId: String
    public let model: String
    public let conversationId: String?
    public let gizmoId: String?
    public let historyAndTrainingDisabled: Bool
    public let conversationMode: ConversationMode?

    public struct ConversationMode: Encodable, Sendable {
        public let kind: String
        public init(kind: String = "primary_assistant") {
            self.kind = kind
        }
    }

    public enum CodingKeys: String, CodingKey {
        case action
        case messages
        case parentMessageId = "parent_message_id"
        case model
        case conversationId = "conversation_id"
        case gizmoId = "gizmo_id"
        case historyAndTrainingDisabled = "history_and_training_disabled"
        case conversationMode = "conversation_mode"
    }

    public init(
        action: String = "next",
        messages: [MessagePayload],
        parentMessageId: String,
        model: String,
        conversationId: String? = nil,
        gizmoId: String? = nil,
        historyAndTrainingDisabled: Bool = false,
        conversationMode: ConversationMode? = ConversationMode()
    ) {
        self.action = action
        self.messages = messages
        self.parentMessageId = parentMessageId
        self.model = model
        self.conversationId = conversationId
        self.gizmoId = gizmoId
        self.historyAndTrainingDisabled = historyAndTrainingDisabled
        self.conversationMode = conversationMode
    }
}

public struct ConversationSummary: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public var title: String
    public let createTime: Double
    public var updateTime: Double
    public let mapping: [String: MessageNode]?
    public var currentNode: String?
    public let gizmoId: String?

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case createTime = "create_time"
        case updateTime = "update_time"
        case mapping
        case currentNode = "current_node"
        case gizmoId = "gizmo_id"
    }

    public init(
        id: String,
        title: String,
        createTime: Double,
        updateTime: Double,
        mapping: [String: MessageNode]? = nil,
        currentNode: String? = nil,
        gizmoId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.createTime = createTime
        self.updateTime = updateTime
        self.mapping = mapping
        self.currentNode = currentNode
        self.gizmoId = gizmoId
    }
}

public struct ConversationListResponse: Codable, Sendable {
    public let items: [ConversationSummary]
    public let total: Int
    public let limit: Int
    public let offset: Int
    public let hasMissingConversations: Bool?

    public enum CodingKeys: String, CodingKey {
        case items
        case total
        case limit
        case offset
        case hasMissingConversations = "has_missing_conversations"
    }
}

public struct ConversationPatchRequest: Encodable, Sendable {
    public let title: String?
    public let isVisible: Bool?

    public enum CodingKeys: String, CodingKey {
        case title
        case isVisible = "is_visible"
    }

    public init(title: String? = nil, isVisible: Bool? = nil) {
        self.title = title
        self.isVisible = isVisible
    }
}
