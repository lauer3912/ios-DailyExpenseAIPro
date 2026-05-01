import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Daily Expense Reminder
    
    func scheduleDailyReminder(at hour: Int = 20, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "💰 Log Today's Expenses"
        content.body = "Don't forget to record your expenses for the day!"
        content.sound = .default
        content.categoryIdentifier = "EXPENSE_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "expense_daily",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily expense reminder: \(error)")
            }
        }
    }
    
    // MARK: - Budget Alert
    
    func scheduleBudgetAlert(categoryName: String, percentUsed: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Budget Alert: \(categoryName)"
        content.body = "You've used \(percentUsed)% of your \(categoryName) budget. Consider slowing down."
        content.sound = .default
        content.categoryIdentifier = "BUDGET_ALERT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "budget_alert_\(categoryName.hashValue)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule budget alert: \(error)")
            }
        }
    }
    
    func scheduleBudgetExceededAlert(categoryName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 \(categoryName) Budget Exceeded!"
        content.body = "You've gone over your \(categoryName) budget. Time to review your spending."
        content.sound = .default
        content.categoryIdentifier = "BUDGET_EXCEEDED"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "budget_exceeded_\(categoryName.hashValue)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule budget exceeded alert: \(error)")
            }
        }
    }
    
    // MARK: - Weekly Summary
    
    func scheduleWeeklySummary(at hour: Int = 18, minute: Int = 0, weekday: Int = 6) {
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Expense Summary"
        content.body = "Your weekly expense report is ready. See how you spent this week!"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_SUMMARY"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "expense_weekly",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule weekly summary: \(error)")
            }
        }
    }
    
    // MARK: - Cancel
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
