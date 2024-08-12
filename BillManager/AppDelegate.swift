//
//  AppDelegate.swift
//  BillManager
//

import UIKit

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.setupNotificationActions()
            } else {
                print("Notification permission denied.")
            }
        }
        return true
    }

    func setupNotificationActions() {
        let remindLaterAction = UNNotificationAction(
            identifier: "remindLater",
            title: "Remind me in an hour",
            options: []
        )
        
        let markAsPaidAction = UNNotificationAction(
            identifier: "markAsPaid",
            title: "Mark as Paid",
            options: [.authenticationRequired]
        )
        
        let category = UNNotificationCategory(
            identifier: Bill.notificationCategoryID,
            actions: [remindLaterAction, markAsPaidAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        
        if identifier == "remindLater" {
            // Handle the "Remind me in an hour" action
            let newTriggerDate = Date().addingTimeInterval(3600)
            let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: response.notification.request.identifier,
                content: response.notification.request.content,
                trigger: newTrigger
            )
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else if identifier == "markAsPaid" {
            // Handle the "Mark as Paid" action
            let billID = response.notification.request.content.userInfo["billID"] as? String
            // Assuming you have a way to get the bill object by its ID
            if let id = billID, var bill = Database.shared.getBill(withID: UUID(uuidString: id)!) {
                bill.paidDate = Date()
                Database.shared.updateAndSave(bill)
            }
        }
        
        completionHandler()
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle discarded scene sessions if necessary
    }
}
