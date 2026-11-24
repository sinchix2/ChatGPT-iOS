import SwiftUI
import SwiftData

// MARK: - Main iOS Application Entry Point

@main
struct ChatGPTApp: App {
    @State private var chatViewModel = ChatViewModel()
    @State private var conversationListViewModel = ConversationListViewModel()
    @State private var isSidebarOpen: Bool = false
    @State private var showSettings: Bool = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DBConversationEntity.self,
            DBMessageEntity.self,
            DBMessageChunkEntity.self,
            DBWebSocketTopicOffsetEntity.self,
            DBCalpicoRoomCacheEntity.self,
            DBCalpicoUserCacheEntity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }
    }()

    init() {
        BackgroundTaskManager.shared.registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Primary Chat View
                ChatView(viewModel: chatViewModel) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isSidebarOpen = true
                    }
                }
                .disabled(isSidebarOpen)

                // Sidebar Drawer Overlay
                if isSidebarOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                isSidebarOpen = false
                            }
                        }

                    HStack(spacing: 0) {
                        SidebarView(
                            listViewModel: conversationListViewModel,
                            onSelectConversation: { convId in
                                withAnimation {
                                    isSidebarOpen = false
                                }
                                chatViewModel.clearChat()
                                chatViewModel.currentConversationId = convId
                            },
                            onNewChat: {
                                withAnimation {
                                    isSidebarOpen = false
                                }
                                chatViewModel.clearChat()
                            },
                            onOpenSettings: {
                                showSettings = true
                            }
                        )
                        .frame(width: min(UIScreen.main.bounds.width * 0.82, 320))
                        .background(Color(uiColor: .systemBackground))
                        .transition(.move(edge: .leading))

                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .modelContainer(sharedModelContainer)
        }
    }

    private func handleDeepLink(_ url: URL) {
        // Handle universal link routing (matching ChatGptDeeplinkActivity)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        if components.path.hasPrefix("/c/") {
            let convId = String(components.path.dropFirst(3))
            chatViewModel.clearChat()
            chatViewModel.currentConversationId = convId
        } else if components.path == "/subscription" || components.path == "/up/" {
            showSettings = true
        }
    }
}
