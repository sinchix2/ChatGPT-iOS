import Foundation
import SwiftUI

// MARK: - Conversation List & History ViewModel

@MainActor
@Observable
public final class ConversationListViewModel {
    public var conversations: [ConversationSummary] = []
    public var filteredConversations: [ConversationSummary] = []
    public var searchQuery: String = "" {
        didSet { applyFilter() }
    }
    public var isLoading: Bool = false
    public var errorMessage: String?

    private let networkClient: OpenAINetworkClient
    private var currentOffset: Int = 0
    private let pageSize: Int = 28
    private var hasMorePages: Bool = true

    public init(networkClient: OpenAINetworkClient = .shared) {
        self.networkClient = networkClient
    }

    public func loadConversations(refresh: Bool = false) async {
        if refresh {
            currentOffset = 0
            hasMorePages = true
            conversations.removeAll()
        }

        guard !isLoading && hasMorePages else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response: ConversationListResponse = try await networkClient.execute(
                .conversationsList(offset: currentOffset, limit: pageSize)
            )

            if refresh {
                conversations = response.items
            } else {
                conversations.append(contentsOf: response.items)
            }

            currentOffset += response.items.count
            hasMorePages = response.items.count >= pageSize
            applyFilter()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    public func deleteConversation(id: String) async {
        conversations.removeAll { $0.id == id }
        applyFilter()

        do {
            let _: EmptyResponse = try await networkClient.execute(.deleteConversation(id: id))
        } catch {
            // Re-fetch on failure
            await loadConversations(refresh: true)
        }
    }

    public func renameConversation(id: String, newTitle: String) async {
        if let idx = conversations.firstIndex(where: { $0.id == id }) {
            conversations[idx].title = newTitle
            applyFilter()
        }

        let request = ConversationPatchRequest(title: newTitle)
        do {
            let _: EmptyResponse = try await networkClient.execute(.updateConversation(id: id, request: request))
        } catch {
            // Suppress minor rename error
        }
    }

    private func applyFilter() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            filteredConversations = conversations
        } else {
            filteredConversations = conversations.filter {
                $0.title.lowercased().contains(query)
            }
        }
    }
}

public struct EmptyResponse: Decodable, Sendable {}
