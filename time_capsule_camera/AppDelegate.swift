import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permission on app launch
        NotificationManager.shared.requestPermission()

        return true
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // You can send the token to your server or save it in Firestore for this user
        print("Firebase registration token: \(fcmToken ?? "")")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        
        switch identifier {
        case "VIEW_CAPSULE":
            // Handle view capsule action
            // You could post a notification to navigate to the specific capsule
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenCapsule"),
                object: nil,
                userInfo: ["notificationId": response.notification.request.identifier]
            )
        case "VIEW_LATER":
            // User chose to view later, maybe schedule a reminder
            break
        default:
            // Default tap action
            break
        }
        
        completionHandler()
    }
}
