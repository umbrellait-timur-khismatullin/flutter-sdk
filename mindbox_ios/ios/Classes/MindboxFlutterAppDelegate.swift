import UIKit
import Flutter
import Mindbox
import MindboxNotifications

open class MindboxFlutterAppDelegate: FlutterAppDelegate{
   open override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Enabling logs
        Mindbox.logger.logLevel = .debug
    
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        registerForRemoteNotifications()
        
        // Регистрация фоновых задач для iOS выше 13
        if #available(iOS 13.0, *) {
            Mindbox.shared.registerBGTasks()
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        }
        
        // Передача факта открытия приложения
        Mindbox.shared.track(.launch(launchOptions))
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //    MARK: didRegisterForRemoteNotificationsWithDeviceToken
    //    Передача токена APNS в SDK Mindbox
    open override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Mindbox.shared.apnsTokenUpdate(deviceToken: deviceToken)
    }
    
    // Регистрация фоновых задач для iOS до 13
    open override func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Mindbox.shared.application(application, performFetchWithCompletionHandler: completionHandler)
    }
    
    //    MARK: registerForRemoteNotifications
    //    Функция запроса разрешения на уведомления. В комплишн блоке надо передать статус разрешения в SDK Mindbox
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().delegate = self
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                print("Permission granted: \(granted)")
                if let error = error {
                    print("NotificationsRequestAuthorization failed with error: \(error.localizedDescription)")
                }
                Mindbox.shared.notificationsRequestAuthorization(granted: granted)
            }
        }
    }
    
    open override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // Передача ссылки во Flutter
        let link = (userActivity.webpageURL?.absoluteString ?? "empty") as NSString
        SwiftMindboxIosPlugin.linkReceived(link: link)
        // Передача ссылки, если приложение открыто через universalLink
        Mindbox.shared.track(.universalLink(userActivity))
        return true
    }
    
    open override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    //    MARK: didReceive response
    //    Функция обработки кликов по нотификации
    open override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // передача данных с клика по пушу во Flutter
        SwiftMindboxIosPlugin.pushClicked(response: response)
        
        // передача факта клика по пушу
        Mindbox.shared.pushClicked(response: response)
        
        // передача факта открытия приложения по переходу на пуш
        Mindbox.shared.track(.push(response))
        
        completionHandler()
    }
    
//    open override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        //todo fix force unwrap
//        Mindbox.shared.track(.universalLink(app.userActivity!))
//        SwiftMindboxIosPlugin.linkReceived(link: url.absoluteString as NSString)
//        return true
//      }
}
