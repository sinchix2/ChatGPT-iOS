import Foundation
import SwiftData

// MARK: - SwiftData Persistence Schema (Matching Android Room DB)

@Model
public final class DBConversationEntity {
    @Attribute(.unique) public var id: String
    public var rawConversationJSON: String
    public var title: String
    public var createTime: Double
    public var updateTime: Double
    public var currentNodeId: String?
    public var gizmoId: String?

    @Relationship(deleteRule: .cascade, inverse: \DBMessageEntity.conversation)
    public var messages: [DBMessageEntity] = []

    public init(
        id: String,
        rawConversationJSON: String,
        title: String,
        createTime: Double,
        updateTime: Double,
        currentNodeId: String? = nil,
        gizmoId: String? = nil
    ) {
        self.id = id
        self.rawConversationJSON = rawConversationJSON
        self.title = title
        self.createTime = createTime
        self.updateTime = updateTime
        self.currentNodeId = currentNodeId
        self.gizmoId = gizmoId
    }
}

@Model
public final class DBMessageEntity {
    @Attribute(.unique) public var id: String
    public var conversationId: String
    public var rawMessageNodeJSON: String
    public var roleRaw: String
    public var contentText: String
    public var createTime: Double
    public var parentId: String?

    public var conversation: DBConversationEntity?

    @Relationship(deleteRule: .cascade, inverse: \DBMessageChunkEntity.message)
    public var chunks: [DBMessageChunkEntity] = []

    public init(
        id: String,
        conversationId: String,
        rawMessageNodeJSON: String,
        roleRaw: String,
        contentText: String,
        createTime: Double,
        parentId: String? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.rawMessageNodeJSON = rawMessageNodeJSON
        self.roleRaw = roleRaw
        self.contentText = contentText
        self.createTime = createTime
        self.parentId = parentId
    }
}

@Model
public final class DBMessageChunkEntity {
    public var messageId: String
    public var chunkIndex: Int
    public var chunkData: Data

    public var message: DBMessageEntity?

    public init(messageId: String, chunkIndex: Int, chunkData: Data) {
        self.messageId = messageId
        self.chunkIndex = chunkIndex
        self.chunkData = chunkData
    }
}

@Model
public final class DBWebSocketTopicOffsetEntity {
    @Attribute(.unique) public var topicId: String
    public var offset: String?

    public init(topicId: String, offset: String? = nil) {
        self.topicId = topicId
        self.offset = offset
    }
}

@Model
public final class DBCalpicoRoomCacheEntity {
    @Attribute(.unique) public var id: String
    public var updatedAt: Int64
    public var payload: String

    public init(id: String, updatedAt: Int64, payload: String) {
        self.id = id
        self.updatedAt = updatedAt
        self.payload = payload
    }
}

@Model
public final class DBCalpicoUserCacheEntity {
    @Attribute(.unique) public var accountUserId: String
    public var payload: String

    public init(accountUserId: String, payload: String) {
        self.accountUserId = accountUserId
        self.payload = payload
    }
}
