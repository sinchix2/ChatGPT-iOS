import Foundation

// MARK: - OpenAI Backend Endpoints

public enum OpenAIEndpoint: Sendable {
    case conversationStream(request: ConversationRequest)
    case conversationsList(offset: Int, limit: Int)
    case conversationDetail(id: String)
    case updateConversation(id: String, request: ConversationPatchRequest)
    case deleteConversation(id: String)
    case accountCheck
    case modelsList
    case gizmosList(cursor: String?)
    case gizmoDetail(id: String)
    case createVoiceSession(conversationId: String?, voice: VoicePreset)

    public var path: String {
        switch self {
        case .conversationStream:
            return "/backend-api/f/conversation"
        case .conversationsList(let offset, let limit):
            return "/backend-api/conversations?offset=\(offset)&limit=\(limit)&order=updated"
        case .conversationDetail(let id):
            return "/backend-api/conversation/\(id)"
        case .updateConversation(let id, _):
            return "/backend-api/conversation/\(id)"
        case .deleteConversation(let id):
            return "/backend-api/conversation/\(id)"
        case .accountCheck:
            return "/backend-api/accounts/check/v4-2023-04-27"
        case .modelsList:
            return "/backend-api/models"
        case .gizmosList(let cursor):
            if let cursor = cursor, !cursor.isEmpty {
                return "/backend-api/gizmos/discovery?cursor=\(cursor)"
            }
            return "/backend-api/gizmos/discovery"
        case .gizmoDetail(let id):
            return "/backend-api/gizmos/\(id)"
        case .createVoiceSession:
            return "/backend-api/realtime/sessions"
        }
    }

    public var httpMethod: String {
        switch self {
        case .conversationStream, .createVoiceSession:
            return "POST"
        case .updateConversation:
            return "PATCH"
        case .deleteConversation:
            return "DELETE"
        case .conversationsList, .conversationDetail, .accountCheck, .modelsList, .gizmosList, .gizmoDetail:
            return "GET"
        }
    }

    public func buildRequest(baseUrl: URL, token: String?) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("ChatGPT/1.2026.300 (iOS; iPhone; Scale/3.00)", forHTTPHeaderField: "User-Agent")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .conversationStream(let convRequest):
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(convRequest)

        case .updateConversation(_, let patchRequest):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(patchRequest)

        case .createVoiceSession(let convId, let voice):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let payload: [String: Any] = [
                "conversation_id": convId as Any,
                "voice": voice.rawValue
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: payload.compactMapValues { $0 })

        default:
            break
        }

        return request
    }
}
