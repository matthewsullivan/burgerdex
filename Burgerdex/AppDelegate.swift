//
//  AppDelegate.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        
        UINavigationBar.appearance().backgroundColor = colour
        UIApplication.shared.statusBarView?.backgroundColor = colour
        
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        registerForPushNotifications()
        
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationSettings()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        
        var fetchedToken = ""
        
        if((UserDefaults.standard.object(forKey: "deviceToken")) != nil){
            
            fetchedToken = UserDefaults.standard.object(forKey: "deviceToken") as! String
        }
    
        if(fetchedToken != token){
            
            let sharedSession = URLSession.shared
            
            Account.insertToken(token: token, session: sharedSession , completion: { (data) in
                
                if (data[0] as! Int) == 1{
                    
                    print("Save to defaults");
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.set(token, forKey: "deviceToken")
                    
                    
                }
                
            })
            
        }else{
            
            print("Token is the same as what is in the database, on the device, and what has been generated");
            
        }
    
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            }) 
        }
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


}

extension UIApplication {
    
    var statusBarView : UIView? {
        
        return value(forKey: "statusBar") as? UIView
    }
}
