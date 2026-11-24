import Foundation

// MARK: - Custom GPT (Gizmo) Contracts

public struct GizmoAuthor: Codable, Sendable, Equatable {
    public let userId: String?
    public let displayName: String
    public let linkTo: URL?

    public enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case linkTo = "link_to"
    }

    public init(userId: String? = nil, displayName: String, linkTo: URL? = nil) {
        self.userId = userId
        self.displayName = displayName
        self.linkTo = linkTo
    }
}

public struct Gizmo: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let description: String?
    public let avatarUrl: URL?
    public let author: GizmoAuthor
    public let categories: [String]?
    public let tools: [String]?
    public let welcomeMessage: String?

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case avatarUrl = "avatar_url"
        case author
        case categories
        case tools
        case welcomeMessage = "welcome_message"
    }

    public init(
        id: String,
        name: String,
        description: String? = nil,
        avatarUrl: URL? = nil,
        author: GizmoAuthor,
        categories: [String]? = nil,
        tools: [String]? = nil,
        welcomeMessage: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.avatarUrl = avatarUrl
        self.author = author
        self.categories = categories
        self.tools = tools
        self.welcomeMessage = welcomeMessage
    }
}

public struct GizmoFeedResponse: Codable, Sendable {
    public let items: [Gizmo]
    public let cursor: String?

    public init(items: [Gizmo], cursor: String? = nil) {
        self.items = items
        self.cursor = cursor
    }
}
