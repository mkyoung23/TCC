import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func scheduleUnsealNotification(for capsule: Capsule) {
        let content = UNMutableNotificationContent()
        content.title = "Time Capsule Unsealed! 🎉"
        content.body = "Your capsule '\(capsule.name)' is now ready to view!"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // Add action buttons
        let viewAction = UNNotificationAction(
            identifier: "VIEW_CAPSULE",
            title: "View Now",
            options: [.foreground]
        )
        
        let laterAction = UNNotificationAction(
            identifier: "VIEW_LATER",
            title: "Later",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "CAPSULE_UNSEALED",
            actions: [viewAction, laterAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "CAPSULE_UNSEALED"
        
        // Schedule for the seal date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: capsule.sealDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "capsule_\(capsule.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for capsule: \(capsule.name)")
            }
        }
    }
    
    func cancelUnsealNotification(for capsuleId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["capsule_\(capsuleId)"])
    }
    
    func scheduleReminderNotification(for capsule: Capsule, daysBeforeUnseal: Int) {
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBeforeUnseal, to: capsule.sealDate)
        
        guard let reminderDate = reminderDate, reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time Capsule Reminder"
        content.body = "Your capsule '\(capsule.name)' unseals in \(daysBeforeUnseal) day\(daysBeforeUnseal == 1 ? "" : "s")!"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "reminder_\(capsule.id)_\(daysBeforeUnseal)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}