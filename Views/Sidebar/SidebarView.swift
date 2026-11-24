import SwiftUI

// MARK: - Navigation Sidebar Drawer

public struct SidebarView: View {
    @Bindable public var listViewModel: ConversationListViewModel
    public let onSelectConversation: (String) -> Void
    public let onNewChat: () -> Void
    public let onOpenSettings: () -> Void

    public init(
        listViewModel: ConversationListViewModel,
        onSelectConversation: @escaping (String) -> Void,
        onNewChat: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.listViewModel = listViewModel
        self.onSelectConversation = onSelectConversation
        self.onNewChat = onNewChat
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Search & New Chat
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search", text: $listViewModel.searchQuery)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Button {
                        onNewChat()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Conversation History List
            List {
                Section {
                    ForEach(listViewModel.filteredConversations) { conv in
                        Button {
                            onSelectConversation(conv.id)
                        } label: {
                            Text(conv.title)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    await listViewModel.deleteConversation(id: conv.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("Recent Chats")
                }
            }
            .listStyle(.plain)

            Divider()

            // User Profile & Settings Footer
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("User Account")
                        .font(.subheadline.bold())
                    Text("Free Plan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onOpenSettings()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .task {
            await listViewModel.loadConversations()
        }
    }
}
