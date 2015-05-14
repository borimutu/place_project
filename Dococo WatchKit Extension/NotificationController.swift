//
//  NotificationController.swift
//  Dococo WatchKit Extension
//
//  Created by 母利 睦人 on 2015/04/11.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {
    @IBOutlet var messageLabel: WKInterfaceLabel!

    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
        println("initialization of watch kit notification")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println("watch will active")

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        println("watch did deactivate")

    }

    /*
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    */
    
    /*
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    */
}
