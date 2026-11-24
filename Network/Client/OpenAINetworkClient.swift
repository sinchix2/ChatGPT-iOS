import Foundation

// MARK: - OpenAI Network Client Actor

public actor OpenAINetworkClient {
    public static let shared = OpenAINetworkClient()

    private let session: URLSession
    private let baseUrl: URL
    private let authBaseUrl: URL
    private let sseReader: SSEStreamReader
    private let decoder: JSONDecoder

    public init(
        baseUrl: URL = URL(string: "https://android.chat.openai.com")!,
        authBaseUrl: URL = URL(string: "https://auth.openai.com")!,
        session: URLSession = .shared
    ) {
        self.baseUrl = baseUrl
        self.authBaseUrl = authBaseUrl
        self.session = session
        self.sseReader = SSEStreamReader()
        self.decoder = JSONDecoder()
    }

    public func execute<T: Decodable>(_ endpoint: OpenAIEndpoint) async throws -> T {
        let token = await KeychainManager.shared.get(key: .accessToken)
        let request = try endpoint.buildRequest(baseUrl: baseUrl, token: token)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 401 {
            // Attempt token refresh
            let refreshed = try await refreshTokenIfNeeded()
            if refreshed {
                let retryToken = await KeychainManager.shared.get(key: .accessToken)
                let retryRequest = try endpoint.buildRequest(baseUrl: baseUrl, token: retryToken)
                let (retryData, retryResponse) = try await session.data(for: retryRequest)
                return try decoder.decode(T.self, from: retryData)
            } else {
                throw SSEError.serverError(statusCode: 401, message: "Unauthorized session")
            }
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw SSEError.serverError(statusCode: httpResponse.statusCode, message: errorMsg)
        }

        return try decoder.decode(T.self, from: data)
    }

    public func executeStream(_ endpoint: OpenAIEndpoint) async throws -> AsyncThrowingStream<ConversationStreamChunk, Error> {
        let token = await KeychainManager.shared.get(key: .accessToken)
        let request = try endpoint.buildRequest(baseUrl: baseUrl, token: token)

        let (asyncBytes, response) = try await session.bytes(for: request)
        return sseReader.parseStream(bytes: asyncBytes, response: response)
    }

    public func refreshTokenIfNeeded() async throws -> Bool {
        guard let refreshToken = await KeychainManager.shared.get(key: .refreshToken) else {
            return false
        }

        guard let url = URL(string: "/oauth/token", relativeTo: authBaseUrl) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let tokenReq = TokenRequest.refreshToken(
            refreshToken: refreshToken,
            clientId: "pvd_chatgpt_mobile_client",
            redirectUri: "com.openai.chatgpt://auth0.openai.com/ios/com.openai.chatgpt/callback"
        )
        request.httpBody = try JSONEncoder().encode(tokenReq)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }

        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        try await KeychainManager.shared.save(key: .accessToken, string: tokenResponse.accessToken)
        if let newRefresh = tokenResponse.refreshToken {
            try await KeychainManager.shared.save(key: .refreshToken, string: newRefresh)
        }
        return true
    }
}
