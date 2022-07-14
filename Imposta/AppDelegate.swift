//
//  AppDelegate.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 7/30/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseMessaging
import IQKeyboardManager
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if UserDefaultsHelper.shared.getToken() != "" {
            if UserDefaultsHelper.shared.getUserType() == UserType.Client.rawValue {
                setClientRoot()
            } else {
                setAdvisorRoot()
            }
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        IQKeyboardManager.shared().isEnabled = true
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        
        Siren.shared.wail()
        return true
    }
    
    func setRoot() {
        UserDefaultsHelper.shared.removeAllObjects()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = R.storyboard.main.rootNav()
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func setAdvisorRoot() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = R.storyboard.advisor.advisorTabBarController() //UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "documentNav") as! UINavigationController
        appDelegate.window?.rootViewController  = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func setClientRoot() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = R.storyboard.client.clientTabBarController() //UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "documentNav") as! UINavigationController
        appDelegate.window?.rootViewController  = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("impostaShare") == .orderedSame,
            let view = url.host {
            print("resolvingAgainstBaseURL \(url)")
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
                print("parametername \(parameters[$0.name])")
                print("parametervalue \($0.value)")
            }
            
//            redirect(to: view, with: parameters)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "FileManager")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveFile(type: DocumentType, document: ResultDocument, path: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fileEntity = NSEntityDescription.entity(forEntityName: "Files", in: managedContext)!
        
        let file = NSManagedObject(entity: fileEntity, insertInto: managedContext)
        file.setValue(path, forKey: "path")
        file.setValue(type.rawValue, forKey: "type")
        file.setValue("".getCurrentDate(), forKey: "date")
        file.setValue(document.service?.name ?? "", forKey: "serviceName")
        file.setValue(document.attachment?.fileName ?? "", forKey: "fileName")
        file.setValue(UserDefaultsHelper.shared.getUserType(), forKey: "user")
        file.setValue(document.client?.name ?? "", forKey: "accountName")
        file.setValue(document.attachment?.genFileName ?? "", forKey: "genFileName")
        
        do {
            try managedContext.save()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func retriveFiles() -> [RetriveFiles]? {
        var arrFiles = [RetriveFiles]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest   <NSFetchRequestResult>(entityName: "Files")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if let path = data.value(forKey: "path") as? String,
                   let date = data.value(forKey: "date") as? String,
                   let type = data.value(forKey: "type") as? String,
                   let user = data.value(forKey: "user") as? String,
                   let fileName = data.value(forKey: "fileName") as? String,
                   let genFileName = data.value(forKey: "genFileName") as? String,
                   let serviceName = data.value(forKey: "serviceName") as? String,
                   let accountName = data.value(forKey: "accountName") as? String                     {
                    
                    let file = RetriveFiles(path: path, date: date, type: type, user: user, fileName: fileName, genFileName: genFileName, serviceName: serviceName, accountName: accountName)
                    arrFiles.append(file)
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        return arrFiles
    }
}

// MARK: - Handle Notifications
extension AppDelegate : UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.message ?? "")")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("firebase fcm token ", fcmToken)
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
