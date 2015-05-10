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
        /*scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.06)
        
        //MARK : - スクロールビューの設置
        scrollView.pagingEnabled = true
        scrollView.scrollEnabled = true
        scrollView.directionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        //MARK : - 各種ボタンの設置
        addFriendButton = HTPressableButton(frame: CGRectMake(self.view.center.x-self.view.frame.width/6, 60, self.view.frame.width/3, self.view.frame.height/10), buttonStyle: HTPressableButtonStyle.Rounded)
        addFriendButton?.setTitle("友達追加", forState: UIControlState.Normal)
        addFriendButton?.backgroundColor = UIColor.ht_aquaColor()
        addFriendButton?.addTarget(self, action: "addFriendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(addFriendButton!)
        
        profileButton = HTPressableButton(frame: CGRectMake(self.view.center.x-self.view.frame.width/6, addFriendButton!.center.y+50.0, self.view.frame.width/3, self.view.frame.height/10), buttonStyle: HTPressableButtonStyle.Rounded)
        profileButton?.setTitle("プロフィール", forState: UIControlState.Normal)
        profileButton?.backgroundColor = UIColor.ht_aquaColor()
        profileButton?.addTarget(self, action: "profileButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(profileButton!)
        
        settingButton = HTPressableButton(frame: CGRectMake(self.view.center.x-self.view.frame.width/6, profileButton!.center.y+50.0, self.view.frame.width/3, self.view.frame.height/10), buttonStyle: HTPressableButtonStyle.Rounded)
        settingButton?.setTitle("設定", forState: UIControlState.Normal)
        settingButton?.backgroundColor = UIColor.ht_aquaColor()
        settingButton?.addTarget(self, action: "settingButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(settingButton!)
        */
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableViewのデリゲートメソッド
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        println("cell")
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        if indexPath.section == 0{
            cell.textLabel?.text = "友達追加"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }else if indexPath.section == 1{
            cell.textLabel?.text = "プロフィール"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }/*else if indexPath.section == 2{
            cell.textLabel?.text = "設定"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }*/
        else{
            println("エラー")
        }
        return cell
        /*let cell : FriendsTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendsTableViewCell") as FriendsTableViewCell
        var friendData = friendsArray[indexPath.row]
        friendData.fetchInBackgroundWithBlock { (object :PFObject!, error :NSError!) -> Void in
            var friend = object as PFUser!
            cell.nameLabel.text = friend.objectForKey("name") as? String
            var pictureFile: PFFile! = friend.objectForKey("profilePicture") as PFFile
            pictureFile.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                var pictureImage = UIImage(data: data)
                cell.userImageView.image = pictureImage
            })
        }
        self.activityIndicator.stopAnimating()
        return cell*/
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 30))
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            self.addFriendButtonTapped()
        }else if indexPath.section == 1{
            self.profileButtonTapped()
        }else{
            println("エラー発生、指定セクション存在せず")
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
