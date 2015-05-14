//
//  InterfaceController.swift
//  Dococo WatchKit Extension
//
//  Created by 母利 睦人 on 2015/04/11.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        println("watch did active")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println("watchがアクティブになる")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        println("viewがアクティブじゃなくなった")
    }

}
