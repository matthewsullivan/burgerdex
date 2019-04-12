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
    
    var visibleViewController: UIViewController? {
        return getVisibleViewController(nil)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupNavigationAndStatusBarLayout()
        
        registerForPushNotifications()
        
        return true
    }
    
    func setupNavigationAndStatusBarLayout(){
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        
        var preferredStatusBarStyle : UIStatusBarStyle {
            return .lightContent
        }

        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)

        UIApplication.shared.statusBarView?.backgroundColor = colour
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = colour
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in 
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
                    let defaults = UserDefaults.standard
                    
                    defaults.set(token, forKey: "deviceToken")
                }
            })
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            }) 
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "dismiss" {}
        
        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}
    

    func applicationDidBecomeActive(_ application: UIApplication) {
        visibleViewController?.navigationController?.isNavigationBarHidden = false
    }

    func applicationWillTerminate(_ application: UIApplication) {}
    
    private func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        let rootVC = rootViewController ?? UIApplication.shared.keyWindow?.rootViewController
        
        if rootVC!.isKind(of: UINavigationController.self) {
            let navigationController = rootVC as! UINavigationController
            return getVisibleViewController(navigationController.viewControllers.last!)
        }
        
        if rootVC!.isKind(of: UITabBarController.self) {
            let tabBarController = rootVC as! UITabBarController
            return getVisibleViewController(tabBarController.selectedViewController!)
        }
        
        if let presentedVC = rootVC?.presentedViewController {
            return getVisibleViewController(presentedVC)
        }
        
        return rootVC
    }
}

extension UIApplication {
    var statusBarView : UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
