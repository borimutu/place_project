//
//  OthersViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/11.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import HTPressableButton
import SCLAlertView


class OthersViewController: UIViewController ,UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource{
    
    var parentNavigationController : UINavigationController?
    var addFriendButton : HTPressableButton?
    var profileButton : HTPressableButton?
    var settingButton : HTPressableButton?
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        println("view did appear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableViewのデリゲートメソッド
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        println("cell")
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        if indexPath.row == 0{
        cell.textLabel?.text = "友達追加"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }else{
        cell.textLabel?.text = "プロフィール"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 30))
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0{
            self.addFriendButtonTapped()
        }else if indexPath.row == 1{
            self.profileButtonTapped()
        }else{
            println("エラー発生、指定行存在せず")
        }
    }
    
    func addFriendButtonTapped() {
        var newVC : AddFriendViewController = AddFriendViewController()
        //newVC.view.backgroundColor = UIColor.lightGrayColor()
        parentNavigationController!.pushViewController(newVC, animated: true)
    }
    
    func profileButtonTapped() {
        var newVC : ProfileViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("profile") as? ProfileViewController
        parentNavigationController!.pushViewController(newVC, animated: true)
    }
    
    func settingButtonTapped() {
        var newVC : SettingViewController = SettingViewController()
        //newVC.view.backgroundColor = UIColor.lightGrayColor()
        parentNavigationController!.pushViewController(newVC, animated: true)
    }
}
