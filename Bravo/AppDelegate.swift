//
//  AppDelegate.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 11/7/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse
//import OneSignal
import UserNotifications

import FBSDKCoreKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //Keys for dev app
    //let ParseAppID = "CTLT83tmRhI9WG8ryn5faymg4eanXhsDiNhm18dj"
    //let ParseClientKey = "OWOvOsMyzRnfa5E9Swv2adzYiMbwj9vYQlSEY46I"
    
    //Keys for demo app
    let ParseAppID = "32JHVD95oXffMcefSB4VxAVDtrU6H92j35aH679h"
    let ParseClientKey = "gQeZDDWXZk4fLPe1wdvjplI8HMqp9a4YfP5n4ahH"
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return handled
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse.
        Parse.setApplicationId(ParseAppID, clientKey: ParseClientKey)
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        configureAppearanceProxies()
        
        //Add this line. Replace '5eb5a37e-b458-11e3-ac11-000c2940e62c' with your OneSignal App ID.
        //OneSignal.initWithLaunchOptions(launchOptions, appId: "5eb5a37e-b458-11e3-ac11-000c2940e62c")
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
        
        /*
         let center = UNUserNotificationCenter.current()
         center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
         // Enable or disable features based on authorization.
         }
         application.registerForRemoteNotifications()
         */
        
        // specifies the settings you want (but won't necessarily get)
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            // the user can, at any time, go into the Settings app and change the notification permissions.
            // must call registerUserNotificationSettings(_:) every time the app launches
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else{
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        // Check current logged in user 
        if PFUser.current() != nil {
            let tabBarController = getTabBarController()
            window?.rootViewController = tabBarController
//            window!.makeKeyAndVisible()
        }
        
        let defaults = UserDefaults.standard
        if let hasSeenWalkthrough = defaults.bool(forKey: "hasSeenWalkthrough") as? Bool{
            if(!hasSeenWalkthrough){
                print("--- walkthrough: NOT SEEN. Showing now")
                showWalkThrough()
            }else{
                print("--- walkthrough: ALREADY SEEN")
            }
        }else{
            print("--- walkthrough: NOT SEEN. Showing now")
            showWalkThrough()
        }
        
        // Print the font family names available in the app
        /*for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }*/
        
        
        return true
    }
    
    func showWalkThrough(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let walkthrough = storyboard.instantiateViewController(withIdentifier: "BWWalkthroughViewController") as! BWWalkthroughViewController
        
        let page1 = storyboard.instantiateViewController(withIdentifier: "walkthrough1")
        let page2 = storyboard.instantiateViewController(withIdentifier: "walkthrough2")
        let page3 = storyboard.instantiateViewController(withIdentifier: "walkthrough3")
        let page4 = storyboard.instantiateViewController(withIdentifier: "walkthrough4")
        
        walkthrough.delegate = walkthrough
        walkthrough.addViewController(vc: page1)
        walkthrough.addViewController(vc: page2)
        walkthrough.addViewController(vc: page3)
        walkthrough.addViewController(vc: page4)
        
        self.window?.rootViewController = walkthrough
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // received notifcation while app is running
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        //When the user accepts or declines your permissions or has already made that selection in the past, a delegate method
        
        // this one specifies the settings the user has granted
    }
    
    @nonobjc func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         // on success
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("--- deviceTokenString: \(deviceTokenString)")
        
        // 9BF809F483D187738AAA4799C7217F599107C7AB21B2314338F0ED86D8E1FFD1
        
        let defaults = UserDefaults.standard
        defaults.set(deviceTokenString, forKey: "deviceTokenString")
        defaults.synchronize()
        
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        
    }
 /*
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
    }
 */
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("---!!! didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)")
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

