//
//  TestTableViewController.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/17/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit
import Parse

class FriendsTableViewController: UITableViewController {
    
    var parentNavigationController : UINavigationController?
    var friendsArray : [PFUser]? = []
    var object = PFObject(className: "TestObject")
    var selectedIndex :Int?
    var activityIndicator: UIActivityIndicatorView!
    var lastUpdate : NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - activityIndicatorの設置、起動
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.center.x-30.0, 100, 60, 60))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        // MARK: - ログインしている場合にtableviewを設置する
        self.tableView.showsVerticalScrollIndicator = true
        // TODO : tableviewのスタイル選択でエラーが出る
        tableView.registerNib(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCell")
        //self.tableView.style = UITableViewStyle.Grouped
        if (PFUser.currentUser() != nil){
            println("ログイン済み")
            friendsArray = PFUser.currentUser().objectForKey("friends") as? [PFUser]
            //TODO: 友達の数が0のときの処理を書く
            if friendsArray?.count == 0 {
                println("friends配列が空です")
                self.activityIndicator.stopAnimating()
            }else{
                println("一人以上友達がいます")
                self.tableView.reloadData()
            }
        }else{
            println("ログインしていない")
        }
        // MARK: - RefreshControlをTableViewに設置
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refreshTableView", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        //TODO: Friendsの配列の中身が存在していなかったり、最終更新がupdateddateよりも新しかった場合、読み込む必要がある。
        if friendsArray?.count == 0{
            if (PFUser.currentUser() != nil){
                println("ログイン済み")
                friendsArray = PFUser.currentUser().objectForKey("friends") as? [PFUser]
                //TODO: 友達の数が0のときの処理を書く
                if friendsArray?.count == 0 {
                    println("friends配列が空です")
                    self.activityIndicator.stopAnimating()
                }else{
                    println("一人以上友達がいます")
                    self.tableView.reloadData()
                }
            }else{
                println("ログインしていない")
            }
        }
        super.viewDidAppear(true)
        
    }
    
    // MARK: - TableViewのデリゲートメソッド
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        println("チェック")
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("number of rows")
        println(friendsArray!.count)
        return friendsArray!.count
     }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell : FriendsTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendsTableViewCell") as FriendsTableViewCell
        var friendData = friendsArray![indexPath.row]
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
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 30))
        let titleLabel = UILabel(frame: CGRectMake(10, 0, 100, 30))
        titleLabel.text = "友達(\(self.friendsArray!.count))"
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
        titleLabel.tintColor = UIColor.whiteColor()
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // MARK: - Appdelegateに、detailViewと共有する変数を設定
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.targetUser = friendsArray![indexPath.row]
        var destinationViewController : DetailViewController = DetailViewController()
        parentNavigationController!.pushViewController(destinationViewController, animated: true)
    }
    
    // MARK: - セグエ
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detail"){
            var vc:DetailViewController = segue.destinationViewController as DetailViewController
        }
    }
    
    // MARK: - Refresh
    func refreshTableView() {
        lastUpdate = NSDate()
        //前回の更新時間とfriendslistの更新時間を比較する。初回検索すなわちlastupdatega
        if (lastUpdate!.compare(PFUser.currentUser().updatedAt) == NSComparisonResult.OrderedDescending){
            print("- 日付が対象より古い")
            refreshControl?.endRefreshing()
        }else if (lastUpdate!.compare(PFUser.currentUser().updatedAt) == NSComparisonResult.OrderedAscending){
            print("- 日付が対象より新しい")
        }else{
            refreshControl?.endRefreshing()
            print("- 日付が同じです")
        }
    }

}