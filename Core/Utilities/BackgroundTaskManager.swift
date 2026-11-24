import Foundation
import BackgroundTasks
import UIKit

// MARK: - Background Task & Service Manager (Ported from Android WorkManager / Foreground Services)

public final class BackgroundTaskManager {
    public static let shared = BackgroundTaskManager()

    public static let refreshTaskId = "com.openai.chatgpt.refresh"
    public static let cleanupTaskId = "com.openai.chatgpt.cleanup"

    private init() {}

    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshTaskId, using: nil) { task in
            guard let appRefreshTask = task as? BGAppRefreshTask else { return }
            self.handleAppRefresh(task: appRefreshTask)
        }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.cleanupTaskId, using: nil) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            self.handleDatabaseCleanup(task: processingTask)
        }
    }

    public func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Background task submission ignored if disabled
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let operationTask = Task {
            // Sync active conversations and check for subscription state
            do {
                let _: AccountCheckResponse = try await OpenAINetworkClient.shared.execute(.accountCheck)
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            operationTask.cancel()
        }
    }

    private func handleDatabaseCleanup(task: BGProcessingTask) {
        let operationTask = Task {
            // Clear expired temporary message chunks
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            operationTask.cancel()
        }
    }
}
