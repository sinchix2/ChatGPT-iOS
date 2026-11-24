import Foundation

// MARK: - Account & Subscription Contracts

public enum PlanType: String, Codable, Sendable {
    case free = "free"
    case plus = "plus"
    case team = "team"
    case enterprise = "enterprise"
    case pro = "pro"

    public var displayName: String {
        switch self {
        case .free: return "Free"
        case .plus: return "ChatGPT Plus"
        case .team: return "ChatGPT Team"
        case .enterprise: return "ChatGPT Enterprise"
        case .pro: return "ChatGPT Pro"
        }
    }

    public var isPaid: Bool {
        self != .free
    }
}

public struct AccountInfo: Codable, Sendable, Identifiable {
    public let id: String
    public let planType: PlanType
    public let hasActiveSubscription: Bool
    public let subscriptionPlan: String?
    public let features: [String]?
    public let entitlements: [String]?

    public enum CodingKeys: String, CodingKey {
        case id = "account_id"
        case planType = "plan_type"
        case hasActiveSubscription = "has_active_subscription"
        case subscriptionPlan = "chatgpt_subscription_plan"
        case features
        case entitlements
    }

    public init(
        id: String,
        planType: PlanType,
        hasActiveSubscription: Bool,
        subscriptionPlan: String? = nil,
        features: [String]? = nil,
        entitlements: [String]? = nil
    ) {
        self.id = id
        self.planType = planType
        self.hasActiveSubscription = hasActiveSubscription
        self.subscriptionPlan = subscriptionPlan
        self.features = features
        self.entitlements = entitlements
    }
}

public struct AccountCheckResponse: Codable, Sendable {
    public let accounts: [AccountInfo]
    public let activeAccountId: String?

    public enum CodingKeys: String, CodingKey {
        case accounts
        case activeAccountId = "active_account_id"
    }
}

public struct ModelSpec: Codable, Sendable, Identifiable, Hashable {
    public var id: String { slug }
    public let slug: String
    public let title: String
    public let subtitle: String?
    public let isDefault: Bool
    public let capabilities: [String]?
    public let requiredPlan: PlanType

    public init(
        slug: String,
        title: String,
        subtitle: String? = nil,
        isDefault: Bool = false,
        capabilities: [String]? = nil,
        requiredPlan: PlanType = .free
    ) {
        self.slug = slug
        self.title = title
        self.subtitle = subtitle
        self.isDefault = isDefault
        self.capabilities = capabilities
        self.requiredPlan = requiredPlan
    }

    public static let availableModels: [ModelSpec] = [
        ModelSpec(
            slug: "gpt-4o",
            title: "GPT-4o",
            subtitle: "Most intelligent flagship model for complex multimodal tasks",
            isDefault: true,
            capabilities: ["vision", "web_search", "canvas", "voice", "code_interpreter"],
            requiredPlan: .free
        ),
        ModelSpec(
            slug: "o1",
            title: "o1",
            subtitle: "Advanced reasoning model for mathematics, coding, and science",
            isDefault: false,
            capabilities: ["deep_reasoning"],
            requiredPlan: .plus
        ),
        ModelSpec(
            slug: "gpt-4o-mini",
            title: "GPT-4o mini",
            subtitle: "Fastest lightweight model for everyday tasks",
            isDefault: false,
            capabilities: ["vision", "web_search", "code_interpreter"],
            requiredPlan: .free
        )
    ]
}
