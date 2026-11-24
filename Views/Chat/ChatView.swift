import SwiftUI

// MARK: - Primary Chat Screen

public struct ChatView: View {
    @Bindable public var viewModel: ChatViewModel
    public let onOpenSidebar: () -> Void

    @State private var showModelPicker: Bool = false
    @State private var showVoiceMode: Bool = false
    @FocusState private var isInputFocused: Bool

    public init(viewModel: ChatViewModel, onOpenSidebar: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onOpenSidebar = onOpenSidebar
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                if viewModel.messages.isEmpty {
                    emptyStateView
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubbleView(
                                        message: message,
                                        onCopy: { text in
                                            UIPasteboard.general.string = text
                                        },
                                        onRegenerate: message.author.role == .assistant ? {
                                            viewModel.sendMessage()
                                        } : nil
                                    )
                                    .id(message.id)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            if let lastId = viewModel.messages.last?.id {
                                withAnimation {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Sticky Bottom Input Bar
                bottomInputBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onOpenSidebar()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Button {
                        showModelPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.activeModel.title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(Capsule())
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.clearChat()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showModelPicker) {
                ModelPickerSheet(selectedModel: $viewModel.activeModel) { newModel in
                    viewModel.selectModel(newModel)
                }
            }
            .fullScreenCover(isPresented: $showVoiceMode) {
                VoiceModeView(conversationId: viewModel.currentConversationId)
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred.")
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("How can I help you today?")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer()
        }
    }

    private var bottomInputBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 10) {
                // Multimodal Attachment Button
                Button {
                    // Attachment picker
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(Circle())
                }

                // Text Input Field
                TextField("Message", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                // Send or Voice Button
                if viewModel.isGenerating {
                    Button {
                        viewModel.stopGeneration()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                } else if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        viewModel.sendMessage()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }
                } else {
                    Button {
                        showVoiceMode = true
                    } label: {
                        Image(systemName: "headphones")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemBackground))
        }
    }
}
