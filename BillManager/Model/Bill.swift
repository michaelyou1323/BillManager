import Foundation
import UserNotifications

struct Bill: Codable {
    let id: UUID
    var amount: Double?
    var dueDate: Date?
    var paidDate: Date?
    var payee: String?
    var remindDate: Date?
    var notificationID: String? // To track the notification associated with the reminder

    static let notificationCategoryID = "billReminderCategory"

    // Method to remove reminders
    func removeReminder() {
        if let notificationID = notificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        }
    }

    // Mutating method to schedule reminders
    mutating func scheduleReminder(on date: Date, completion: @escaping (Bill) -> Void) {
        var billCopy = self // Create a mutable copy of self
        
        checkNotificationAuthorization { authorized in
            guard authorized else {
                billCopy.notificationID = nil
                completion(billCopy)
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Bill Reminder"
            content.body = "Don't forget to pay \(billCopy.payee ?? "your bill")!"
            content.sound = .default
            content.categoryIdentifier = Bill.notificationCategoryID
            content.userInfo = ["billID": billCopy.id.uuidString]

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            billCopy.notificationID = request.identifier

            UNUserNotificationCenter.current().add(request) { error in
                if error != nil {
                    billCopy.notificationID = nil
                }
                completion(billCopy)
            }
        }
    }




    
    
    // Private method to check notification authorization
    private func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            default:
                completion(false)
            }
        }
    }
    
    
}
