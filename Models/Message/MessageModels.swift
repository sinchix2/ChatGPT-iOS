import Foundation

// MARK: - Message Data Structures

public enum MessageRole: String, Codable, Sendable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
    case tool = "tool"
}

public enum MessageStatus: String, Codable, Sendable {
    case inProgress = "in_progress"
    case finishedSuccessfully = "finished_successfully"
    case failed = "failed"
}

public struct Author: Codable, Sendable, Equatable {
    public let role: MessageRole
    public let name: String?
    public let metadata: [String: String]?

    public init(role: MessageRole, name: String? = nil, metadata: [String: String]? = nil) {
        self.role = role
        self.name = name
        self.metadata = metadata
    }
}

public enum ContentType: String, Codable, Sendable {
    case text = "text"
    case multimodalText = "multimodal_text"
    case code = "code"
    case executionOutput = "execution_output"
    case tetherBrowsingDisplay = "tether_browsing_display"
}

public struct ContentPart: Codable, Sendable, Equatable {
    public let text: String?
    public let assetPointer: String?
    public let mimeType: String?
    public let width: Int?
    public let height: Int?

    public enum CodingKeys: String, CodingKey {
        case text
        case assetPointer = "asset_pointer"
        case mimeType = "mime_type"
        case width
        case height
    }

    public init(text: String) {
        self.text = text
        self.assetPointer = nil
        self.mimeType = nil
        self.width = nil
        self.height = nil
    }

    public init(assetPointer: String, mimeType: String, width: Int? = nil, height: Int? = nil) {
        self.text = nil
        self.assetPointer = assetPointer
        self.mimeType = mimeType
        self.width = width
        self.height = height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringVal = try? container.decode(String.self) {
            self.text = stringVal
            self.assetPointer = nil
            self.mimeType = nil
            self.width = nil
            self.height = nil
            return
        }
        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try keyed.decodeIfPresent(String.self, forKey: .text)
        self.assetPointer = try keyed.decodeIfPresent(String.self, forKey: .assetPointer)
        self.mimeType = try keyed.decodeIfPresent(String.self, forKey: .mimeType)
        self.width = try keyed.decodeIfPresent(Int.self, forKey: .width)
        self.height = try keyed.decodeIfPresent(Int.self, forKey: .height)
    }

    public func encode(to encoder: Encoder) throws {
        if let text = self.text, self.assetPointer == nil {
            var container = encoder.singleValueContainer()
            try container.encode(text)
        } else {
            var keyed = encoder.container(keyedBy: CodingKeys.self)
            try keyed.encodeIfPresent(self.text, forKey: .text)
            try keyed.encodeIfPresent(self.assetPointer, forKey: .assetPointer)
            try keyed.encodeIfPresent(self.mimeType, forKey: .mimeType)
            try keyed.encodeIfPresent(self.width, forKey: .width)
            try keyed.encodeIfPresent(self.height, forKey: .height)
        }
    }
}

public struct MessageContent: Codable, Sendable, Equatable {
    public let contentType: ContentType
    public let parts: [ContentPart]

    public enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case parts
    }

    public init(contentType: ContentType = .text, text: String) {
        self.contentType = contentType
        self.parts = [ContentPart(text: text)]
    }

    public init(contentType: ContentType = .text, parts: [ContentPart]) {
        self.contentType = contentType
        self.parts = parts
    }

    public var joinedText: String {
        parts.compactMap(\.text).joined(separator: "\n")
    }
}

public struct Citation: Codable, Sendable, Equatable {
    public let startIdx: Int
    public let endIdx: Int
    public let text: String?
    public let url: URL?
    public let title: String?

    public enum CodingKeys: String, CodingKey {
        case startIdx = "start_ix"
        case endIdx = "end_ix"
        case text
        case url
        case title
    }
}

public struct MessageMetadata: Codable, Sendable, Equatable {
    public let modelSlug: String?
    public let parentId: String?
    public let citations: [Citation]?
    public let finishDetails: [String: String]?
    public let isComplete: Bool?

    public enum CodingKeys: String, CodingKey {
        case modelSlug = "model_slug"
        case parentId = "parent_id"
        case citations
        case finishDetails = "finish_details"
        case isComplete = "is_complete"
    }

    public init(
        modelSlug: String? = nil,
        parentId: String? = nil,
        citations: [Citation]? = nil,
        finishDetails: [String: String]? = nil,
        isComplete: Bool? = nil
    ) {
        self.modelSlug = modelSlug
        self.parentId = parentId
        self.citations = citations
        self.finishDetails = finishDetails
        self.isComplete = isComplete
    }
}

public struct MessagePayload: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let author: Author
    public let createTime: Double?
    public let updateTime: Double?
    public let content: MessageContent
    public let status: MessageStatus?
    public let endTurn: Bool?
    public let weight: Double?
    public let metadata: MessageMetadata?
    public let recipient: String?

    public enum CodingKeys: String, CodingKey {
        case id
        case author
        case createTime = "create_time"
        case updateTime = "update_time"
        case content
        case status
        case endTurn = "end_turn"
        case weight
        case metadata
        case recipient
    }

    public init(
        id: String = UUID().uuidString,
        author: Author,
        createTime: Double? = Date().timeIntervalSince1970,
        updateTime: Double? = nil,
        content: MessageContent,
        status: MessageStatus? = .finishedSuccessfully,
        endTurn: Bool? = true,
        weight: Double? = 1.0,
        metadata: MessageMetadata? = nil,
        recipient: String? = nil
    ) {
        self.id = id
        self.author = author
        self.createTime = createTime
        self.updateTime = updateTime
        self.content = content
        self.status = status
        self.endTurn = endTurn
        self.weight = weight
        self.metadata = metadata
        self.recipient = recipient
    }
}

public struct MessageNode: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let message: MessagePayload?
    public let parent: String?
    public let children: [String]

    public init(id: String, message: MessagePayload?, parent: String?, children: [String]) {
        self.id = id
        self.message = message
        self.parent = parent
        self.children = children
    }
}
