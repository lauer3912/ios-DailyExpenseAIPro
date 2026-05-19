import SwiftUI

@main
struct DailyExpenseAIProApp: App {
    @StateObject private var store = AppStore()
    @State private var hasRequestedNotifications = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .task {
                    // Sync with StoreKit to check existing purchases
                    await store.syncWithStoreKit()
                }
                .onAppear {
                    store.processRecurringTransactions()
                    setupNotifications()
                }
        }
    }
    
    private func setupNotifications() {
        guard !hasRequestedNotifications else { return }
        hasRequestedNotifications = true
        
        NotificationService.shared.requestPermission { granted in
            if granted {
                NotificationService.shared.scheduleDailyReminder(at: 20, minute: 0)
                NotificationService.shared.scheduleWeeklySummary(at: 18, minute: 0, weekday: 6)
            }
        }
    }
}
