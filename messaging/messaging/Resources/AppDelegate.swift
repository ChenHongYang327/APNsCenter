

import UIKit
import UserNotifications
import RealmSwift


@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    var window : UIWindow?
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]?)
        -> Bool {
            
            // 確認是否收到推播(諮詢權限)
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                
            }
            
            // regist server to Apple
            UIApplication.shared.registerForRemoteNotifications()
            
            //set Delegate for tab notification (UNUserNotificationCenterDelegate)
            UNUserNotificationCenter.current().delegate = self
            
            // 加密鑰匙
            keyFlow()
            
            window = UIWindow(frame: UIScreen.main.bounds)
            let vc = MainViewController()
            let navigationVC = UINavigationController(rootViewController: vc)
            window?.backgroundColor = .white
            window?.makeKeyAndVisible()
            window?.rootViewController = navigationVC
            
            return true
    }
    
    // when regist to Apple success can get "deviceToken" !!!
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var tokenStr = ""
        for byte in deviceToken {
            let hexStr = String(format: "%02x", byte)
            tokenStr += hexStr
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserKeys.notificationObserveKey.rawValue), object: self, userInfo: ["tokenStr":tokenStr])

//        print("MyDevice TokenStr : \(tokenStr)")
    }
    
    // 推播接收時失敗func
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Faild to take notification")
    }
    
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// UNUserNotificationCenter 裡面有資料可以拿 （userInfo）
    
    // ”點擊“ 通知時 App 在背景或還沒啟動時
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        var userInfoStr: String = ""
        
        let userAps = userInfo[AnyHashable("aps")]
        if let dict = userAps as? [AnyHashable: Any] {
            let apsItem = try? JSONDecoder().decode(Aps.self, from: dict.jsonToData!)
            userInfoStr = apsItem.debugDescription
        }

        ///   需轉成data 再用 "AlertResp" 編碼成物件，即可拿出其中參數
        let notificationId = userInfo[AnyHashable(UserKeys.notificationIdForIdentify.rawValue)] as! String
//        print("notificationId:\(notificationId)")
        
        changeStatus(notificationId: notificationId, userInfoStr: userInfoStr)
        
        /// Note
        /*
         1. 查詢型別的寫法
         2. 可以多轉幾次擋，不限於一定要轉內容，像這次就必須要從外頭一起轉才好做事
         
        let userAps = userInfo[AnyHashable("aps")]
        if let dict = userAps as? [AnyHashable: Any] {

            print("---type---")
            print(type(of: dict), dict)
            print("---value of content-available---")

            print(dict["alert"])
        }
        
//        print("---type---")
//        print(type(of: userAps))
//        print("---dump---")
//        dump(userAps)
        
         */
        
        completionHandler()

    }
    
    // ”點擊“ 通知時 App 在前景
    /*
     completionHandler([]) -> 不顯示
     completionHandler([.alert, .sound, .badge]) -> 想顯示啥就加
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert])
    }
    
}

extension AppDelegate {
    
    func changeStatus(notificationId: String, userInfoStr: String){
        
        let realm = Secure.shard.openRealm()
        
        let items = realm!.objects(NotificationRealm.self)
        
        let item = items.where {
            $0.notiPostRealm.device[UserKeys.notificationIdForIdentify.rawValue] == "\(notificationId)"
        }
        if item.isEmpty {
            print("item is empty")
            return
        } else {
            try! realm?.write {
                item[0].isOwnRead = true
                item[0].userInfo = userInfoStr
            }
        }
        
    }
    
    
    func keyFlow() {
        // 確認是否有存鑰匙
        guard let key = UserDefaults.standard.object(forKey: UserKeys.secKey.rawValue) as? String else {
            // 建立一個新的 realm
            Secure.shard.createRealm()
            print("create New Realm")
            return
        }
        
        // 確認鑰匙是否能開鎖，開鎖失敗，建立一個新的，把舊的刪掉
        guard Secure.shard.isKey(keyStr: key) else {
            // 建立一個新的 realm
            Secure.shard.createRealm()
            // 把舊的realm 刪掉
            
            return
        }
        print("密鑰驗證成功")
        
    }
    
}


