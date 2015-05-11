//
//  ViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/11.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//
import UIKit
import PageMenu
import Parse
import CoreLocation

class ViewController: UIViewController, CAPSPageMenuDelegate, CLLocationManagerDelegate{
    
    var pageMenu : CAPSPageMenu?
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // MARK: - NavigationBarの外見を設定
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        let backButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        backButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.backBarButtonItem = backButtonItem
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // MARK: - PageMenuのコンテンツとなる3つのビューを生成
        var controllersArray : [UIViewController] = []
        var friendsTableViewcontroller : FriendsTableViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("friends") as? FriendsTableViewController
        friendsTableViewcontroller.parentNavigationController = self.navigationController
        friendsTableViewcontroller.title = "友達"
        controllersArray.append(friendsTableViewcontroller)
        
        var timelineViewController : TimelineViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("timeline") as? TimelineViewController
        timelineViewController?.title = "タイムライン"
        timelineViewController?.parentNavigationController = self.navigationController
        //controllersArray.append(timelineViewController!)
        
        var othersViewController :OthersViewController? =  self.storyboard?.instantiateViewControllerWithIdentifier("others") as? OthersViewController
        othersViewController?.title = "設定"
        othersViewController?.parentNavigationController = self.navigationController
        controllersArray.append(othersViewController!)
        
        // MARK: - PageMenuのパラメーター設定
        var parameters: [String: AnyObject] = ["menuItemSeparatorWidth": 3.0,
            "scrollMenuBackgroundColor": UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0),
            "viewBackgroundColor": UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1),
            "bottomMenuHairlineColor": UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1),
            "selectionIndicatorColor": UIColor.whiteColor(),
            "menuMargin": 0,
            "menuHeight": 40.0,
            "menuItemWidth": self.view.frame.width/2,
            "selectedMenuItemLabelColor": UIColor.whiteColor(),
            "unselectedMenuItemLabelColor": UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0),
            "menuItemFont": UIFont(name: "HelveticaNeue-Medium", size: 15.0)!,
            "menuItemSeparatorRoundEdges": true,
            "selectionIndicatorHeight": 2.0,
            "menuItemWidthBasedOnTitleTextWidth": false,
            "menuItemSeparatorPercentageHeight": 0.1]

        pageMenu = CAPSPageMenu(viewControllers: controllersArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), options: parameters)
        pageMenu?.hideTopMenuBar = true
        pageMenu!.delegate = self
        self.view.addSubview(pageMenu!.view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // MARK: - ユーザーのログインチェック
        if (PFUser.currentUser() == nil){
            // MARK: - ログインビューに遷移する
            self.performSegueWithIdentifier("login", sender: nil)
        }else{
            // MARK: -  Push通知のためのチャンネル登録
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.addUniqueObject(PFUser.currentUser().objectId, forKey: "channels")
            currentInstallation.saveInBackground()
            let subscribedChannels = PFInstallation.currentInstallation().channels
            currentInstallation.saveInBackground()
        }
    }
}