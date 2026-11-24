import Foundation
import SwiftUI
import Combine

// MARK: - Chat ViewModel (Ported from Android Jetpack Compose UDF ViewModel)

@MainActor
@Observable
public final class ChatViewModel {
    // MARK: - State Properties
    public var currentConversationId: String?
    public var messages: [MessagePayload] = []
    public var activeModel: ModelSpec
    public var inputText: String = ""
    public var isGenerating: Bool = false
    public var errorMessage: String?
    public var showErrorAlert: Bool = false

    private let networkClient: OpenAINetworkClient
    private var streamingTask: Task<Void, Never>?

    public init(
        conversationId: String? = nil,
        networkClient: OpenAINetworkClient = .shared,
        initialModel: ModelSpec = ModelSpec.availableModels[0]
    ) {
        self.currentConversationId = conversationId
        self.networkClient = networkClient
        self.activeModel = initialModel
    }

    // MARK: - Message Actions

    public func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }

        let userMsgId = UUID().uuidString
        let parentId = messages.last?.id ?? "client-root"

        let userMessage = MessagePayload(
            id: userMsgId,
            author: Author(role: .user),
            content: MessageContent(text: trimmed),
            status: .finishedSuccessfully,
            metadata: MessageMetadata(parentId: parentId)
        )

        messages.append(userMessage)
        inputText = ""
        isGenerating = true
        errorMessage = nil

        // Prepare placeholder assistant message
        let assistantMsgId = UUID().uuidString
        let placeholderAssistantMessage = MessagePayload(
            id: assistantMsgId,
            author: Author(role: .assistant, name: activeModel.title),
            content: MessageContent(text: ""),
            status: .inProgress,
            metadata: MessageMetadata(modelSlug: activeModel.slug, parentId: userMsgId)
        )
        messages.append(placeholderAssistantMessage)

        let request = ConversationRequest(
            action: "next",
            messages: [userMessage],
            parentMessageId: parentId,
            model: activeModel.slug,
            conversationId: currentConversationId,
            historyAndTrainingDisabled: !AppSettings.shared.isHistoryAndTrainingEnabled
        )

        streamingTask?.cancel()
        streamingTask = Task {
            do {
                let stream = try await networkClient.executeStream(.conversationStream(request: request))

                for try await chunk in stream {
                    if Task.isCancelled { break }

                    if let newConvId = chunk.conversationId, currentConversationId == nil {
                        currentConversationId = newConvId
                    }

                    if let incomingMessage = chunk.message {
                        if let index = messages.firstIndex(where: { $0.id == assistantMsgId || $0.id == incomingMessage.id }) {
                            messages[index] = incomingMessage
                        }
                    }
                }

                // Finalize assistant message status
                if let lastIdx = messages.indices.last, messages[lastIdx].author.role == .assistant {
                    let finalMessage = messages[lastIdx]
                    messages[lastIdx] = MessagePayload(
                        id: finalMessage.id,
                        author: finalMessage.author,
                        createTime: finalMessage.createTime,
                        content: finalMessage.content,
                        status: .finishedSuccessfully,
                        metadata: finalMessage.metadata
                    )
                }

                isGenerating = false
            } catch {
                if !Task.isCancelled {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true

                    // Mark assistant message as failed if empty
                    if let lastIdx = messages.indices.last, messages[lastIdx].author.role == .assistant {
                        if messages[lastIdx].content.joinedText.isEmpty {
                            messages.remove(at: lastIdx)
                        }
                    }
                }
            }
        }
    }

    public func stopGeneration() {
        streamingTask?.cancel()
        streamingTask = nil
        isGenerating = false
    }

    public func selectModel(_ model: ModelSpec) {
        self.activeModel = model
        AppSettings.shared.selectedModelSlug = model.slug
    }

    public func clearChat() {
        stopGeneration()
        currentConversationId = nil
        messages.removeAll()
        inputText = ""
        errorMessage = nil
    }
}
