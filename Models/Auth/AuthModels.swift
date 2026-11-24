import Foundation

// MARK: - OAuth & Authentication Contracts

public struct TokenRequest: Encodable, Sendable {
    public let grantType: String
    public let clientId: String
    public let code: String?
    public let redirectUri: String
    public let codeVerifier: String?
    public let refreshToken: String?

    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientId = "client_id"
        case code
        case redirectUri = "redirect_uri"
        case codeVerifier = "code_verifier"
        case refreshToken = "refresh_token"
    }

    public static func authorizationCode(
        code: String,
        clientId: String,
        redirectUri: String,
        codeVerifier: String
    ) -> TokenRequest {
        TokenRequest(
            grantType: "authorization_code",
            clientId: clientId,
            code: code,
            redirectUri: redirectUri,
            codeVerifier: codeVerifier,
            refreshToken: nil
        )
    }

    public static func refreshToken(
        refreshToken: String,
        clientId: String,
        redirectUri: String
    ) -> TokenRequest {
        TokenRequest(
            grantType: "refresh_token",
            clientId: clientId,
            code: nil,
            redirectUri: redirectUri,
            codeVerifier: nil,
            refreshToken: refreshToken
        )
    }
}

public struct TokenResponse: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String?
    public let idToken: String?
    public let tokenType: String
    public let expiresIn: Int
    public let scope: String?

    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
    }

    public init(
        accessToken: String,
        refreshToken: String?,
        idToken: String?,
        tokenType: String,
        expiresIn: Int,
        scope: String?
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.scope = scope
    }
}

public struct UserSession: Codable, Sendable, Identifiable {
    public var id: String { accountUserId }
    public let accountUserId: String
    public let accountId: String
    public let email: String?
    public let name: String?
    public let picture: URL?
    public let planType: String

    public enum CodingKeys: String, CodingKey {
        case accountUserId = "account_user_id"
        case accountId = "account_id"
        case email
        case name
        case picture
        case planType = "plan_type"
    }

    public init(
        accountUserId: String,
        accountId: String,
        email: String?,
        name: String?,
        picture: URL?,
        planType: String
    ) {
        self.accountUserId = accountUserId
        self.accountId = accountId
        self.email = email
        self.name = name
        self.picture = picture
        self.planType = planType
    }
}

public struct AuthChallengeResponse: Codable, Sendable {
    public let challengeId: String
    public let challengeType: String
    public let verificationUrl: URL?

    public enum CodingKeys: String, CodingKey {
        case challengeId = "challenge_id"
        case challengeType = "challenge_type"
        case verificationUrl = "verification_url"
    }
}
