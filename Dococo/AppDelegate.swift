//
//  AppDelegate.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/11.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Fabric
import TwitterKit
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var services: AnyObject?
    var message:String?
    var targetUser:PFUser?
    var friends :[String!] = []
    var isFromSignup :Bool!
    var isFromLogin :Bool!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // MARK: - Navigationbarの外見の変更
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        // MARK: - Push通知設定
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }
        
        // MARK: - GoogleMap初期設定
        let googleMapApikey: String? = "AIzaSyCh1k4Rw-AQrIeYYAkOB-YO5S72UAdHmVw"
        if googleMapApikey == nil {
            let bundleId = NSBundle.mainBundle().bundleIdentifier
            var format = "Configure APIKey inside GoogleMapAPIKey.h for your "
            "bundle `\(bundleId)`, see README.GoogleMapsSDKDemos for more information"
            NSException(name:"AppDelegate",reason:format,userInfo:nil).raise()
        }
        GMSServices.provideAPIKey(googleMapApikey)
        services = GMSServices.sharedServices()
        
        // MARK: - Fabric
        Fabric.with([Twitter(), Crashlytics()])
        
        // MARK: - Parse初期設定
        Parse.enableLocalDatastore()
        //TODO: extentionのローカルデータストアをオンにするとアプリがログイン状態を保ってくれない
        //Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.gmail-makomori26.Dococo")
        Parse.setApplicationId("CxgnixQpggcDzru2zM25yuNWyjW1AMkOEKSas1Xc",
            clientKey: "8iBRW7W14PXhCjcvxzalv4J4g02xqwjgaGtmoq3C")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        //PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    // MARK: - Push通知Delegateメソッド
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        println("push通知\(userInfo)")
        
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            println("inactive")
        }else{
            println("active")
        }
    }
}



