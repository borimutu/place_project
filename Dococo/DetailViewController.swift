//
//  DetailViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/12.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import HTPressableButton
import BFPaperButton
import pop
import SCLAlertView
import Parse


class DetailViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var docoButton : HTPressableButton?
    var CocoButton : HTPressableButton?
    var targetUser : PFUser?
    var locationManager : CLLocationManager?
    var mapView: GMSMapView?
    var sentDates : [String] = []
    var posts : [PFObject] = []
    var cocoPosts : [PFObject] = []
    var markers : [GMSMarker] = []
    var activityIndicator: UIActivityIndicatorView!
    var refreshActivityIndicator: UIActivityIndicatorView!
    var refreshControl:UIRefreshControl!
    var lastUpdate : NSDate?
    var formatter :NSDateFormatter = NSDateFormatter()
    @IBOutlet var tableView: UITableView!
    var currentUserImage : UIImage?
    var targetUserImage : UIImage?
    var refreshButton :UIButton?
    var isCocoIndex :[Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - ナビゲーションバーのrightButtonItemに削除ボタンを設置
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "削除", style: UIBarButtonItemStyle.Plain, target: self, action: "deleteFriend:")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.redColor()
        
        // MARK: - Appdelegateから共有変数を取得
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        targetUser = appDelegate.targetUser
        
        //MARK: - GoogleMapViewの設置
        mapView =  GMSMapView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height/2.5))
        mapView?.myLocationEnabled = true
        self.view?.addSubview(mapView!)
        
        //MARK: - CocoButton、DocoButtonの設置
        CocoButton = HTPressableButton(frame: CGRectMake(self.view.frame.width-70.0, self.mapView!.frame.height-70 , 60, 60), buttonStyle: HTPressableButtonStyle.Circular)
        CocoButton?.buttonColor = UIColor.ht_grapeFruitColor()
        CocoButton?.shadowColor = UIColor.ht_grapeFruitDarkColor()
        CocoButton?.setTitle("Coco!", forState: UIControlState.Normal)
        CocoButton?.addTarget(self, action:"cocobuttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(CocoButton!)
        
        docoButton = HTPressableButton(frame: CGRectMake(self.view.frame.width-140, self.mapView!.frame.height-70, 60, 60), buttonStyle: HTPressableButtonStyle.Circular)
        docoButton?.buttonColor = UIColor.ht_grapeFruitColor()
        docoButton?.shadowColor = UIColor.ht_grapeFruitDarkColor()
        docoButton?.setTitle("Doco?", forState: UIControlState.Normal)
        docoButton?.addTarget(self, action:"docobuttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(docoButton!)
        
        //MARK: - LocationManagerの設置、現在地取得開始
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()

        //MARK: - tableview事前準備、設置
        tableView = UITableView(frame: CGRectMake(0, self.mapView!.frame.height, self.view.frame.size.width, self.view.frame.height-self.view.frame.height/2.5-65), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.grayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.registerNib(UINib(nibName: "TargetCocoCell", bundle: nil), forCellReuseIdentifier: "TargetCocoCell")
        tableView.registerNib(UINib(nibName: "TargetDocoCell", bundle: nil), forCellReuseIdentifier: "TargetDocoCell")
        tableView.registerNib(UINib(nibName: "UserCocoCell", bundle: nil), forCellReuseIdentifier: "UserCocoCell")
        tableView.registerNib(UINib(nibName: "UserDocoCell", bundle: nil), forCellReuseIdentifier: "UserDocoCell")
        self.view.addSubview(tableView)
        
        //MARK: - refreshcontrolの設置
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        //MARK: - activity indicatorの設置
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.center.x-30, self.tableView.center.y-30, 60, 60))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        //MARK: - lastUpdateの初期化、現在時刻設定
        lastUpdate = NSDate()
        
        //MARK: - formatter初期化
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        //MARK: - currentUser、targetUserの写真を取得、格納
        var currentUserImageFile: PFFile?
        if PFUser.currentUser().objectForKey("profilePicture") != nil{
             currentUserImageFile = PFUser.currentUser().objectForKey("profilePicture") as? PFFile
            currentUserImageFile?.getDataInBackgroundWithBlock({ (imageData:NSData!, error:NSError!) -> Void in
               self.currentUserImage = UIImage(data: imageData)
            })
        }else{
            println("写真が登録されていない")
        }
        
        var targetUserImageFile: PFFile = targetUser?.objectForKey("profilePicture") as PFFile
        targetUserImageFile.getDataInBackgroundWithBlock { (imageData:NSData!, error:NSError!) -> Void in
            if (error == nil){
                self.targetUserImage = UIImage(data: imageData)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //MARK: - 投稿の取得、描画
        self.getPosts()
    }
    //MARK - : Cocobutton、Docobuttonの挙動の設定
    func cocobuttonTapped(button: UIButton) {
        var object :PFObject = PFObject(className: "Coco")
        object["to"] = targetUser
        object["from"] = PFUser.currentUser()
        PFGeoPoint.geoPointForCurrentLocationInBackground { (point :PFGeoPoint!, error :NSError!) -> Void in
            if (error == nil){
                object["point"] = point
                object.saveInBackgroundWithBlock({ (succeeded :Bool!, error :NSError!) -> Void in
                    if (error == nil){
                        // TODO: GoogleMap上にマーカーを設置
                        var marker:GMSMarker? = GMSMarker()
                        marker?.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
                        marker?.snippet = self.formatter.stringFromDate(object.createdAt)
                        marker?.appearAnimation = kGMSMarkerAnimationPop
                        marker?.map = self.mapView
                        self.mapView?.selectedMarker = marker
                        //MARK: - 追加したマーカーの位置にmapviewを移動
                        self.mapView?.animateToLocation(marker!.position)
                        
                        //MARK: - 保存に成功したPFObjectをpost配列、cocoPosts配列、isCocoIndex配列に保存
                        self.posts.insert(object, atIndex: 0)
                        self.isCocoIndex.insert(true, atIndex: 0)
                        self.cocoPosts.append(object)
                        self.markers.append(marker!)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        // MARK: - ジオポイントから住所を取得
                        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: point.latitude, longitude: point.longitude
                            ), completionHandler: { (object :[AnyObject]!, error :NSError!) -> Void in
                                if (error == nil){
                                    //TODO: 取得した住所を入れるところに入れる
                                }else{
                                }
                        })
                        
                        //MARK: - プッシュ通知を送信
                        let push = PFPush()
                        push.setChannel(self.targetUser?.objectId)
                        var name :NSString! = PFUser.currentUser().objectForKey("name") as NSString
                        push.setMessage("\(name)からCocoが届きました")
                        push.sendPushInBackgroundWithBlock({ (succeeded :Bool!, error :NSError!) -> Void in
                            if (error==nil){
                                println("プッシュ通知成功")
                            }else{
                                println("プッシュ通知失敗")
                            }
                        })
                    }
                })
            }
            else{
                println("ジオポイント取得失敗")
            }
        }
    }
    
    func docobuttonTapped(button: UIButton) {
        var object :PFObject = PFObject(className: "Doco")
        object["to"] = targetUser
        object["from"] = PFUser.currentUser()
        PFGeoPoint.geoPointForCurrentLocationInBackground { (point :PFGeoPoint!, error :NSError!) -> Void in
            if (error == nil){
                object["point"] = point
                object.saveInBackgroundWithBlock({ (succeeded :Bool!, error :NSError!) -> Void in
                    if (error == nil){
                        //MARK: - 保存に成功したPFObjectをpost配列、cocoPosts配列、isCocoIndex配列に保存
                        self.posts.insert(object, atIndex: 0)
                        self.isCocoIndex.insert(false, atIndex: 0)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        
                        //MARK: - プッシュ通知を送信
                        let push = PFPush()
                        push.setChannel(self.targetUser?.objectId)
                        var name :NSString! = PFUser.currentUser().objectForKey("name") as NSString
                        push.setMessage("\(name)からDocoが届きました")
                        push.sendPushInBackgroundWithBlock({ (succeeded :Bool!, error :NSError!) -> Void in
                            if (error==nil){
                                println("push notification succeeded")
                            }else{
                                println("push notificatin failed")
                            }
                        })
                    }
                })
            }
            else{
                println("error occured")
            }
        }
        
    }
    
    //TODO: 現在地取得後、GoogleMapの位置を移動、現在地取得をストップ
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        println("現在地取得成功")
        if (newLocation != oldLocation){
            var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:newLocation.coordinate.latitude,longitude:newLocation.coordinate.longitude)
            var currentLocationCamera :GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude,longitude:coordinate.longitude,zoom:17)
            mapView?.camera = currentLocationCamera
            locationManager?.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("現在地取得失敗")
    }
    
    // MARK: - ユーザー、ターゲットユーザーによる投稿を取得、配列に格納
    func getPosts() {
        //4つのqueryを作り、二つの統合queryを作る
        var userCocoQuery = PFQuery(className: "Coco")
        var userDocoQuery = PFQuery(className: "Doco")
        var targetCocoQuery = PFQuery(className: "Coco")
        var targetDocoQuery = PFQuery(className: "Doco")
        userCocoQuery.whereKey("to", equalTo: targetUser)
        userCocoQuery.whereKey("from", equalTo: PFUser.currentUser())
        userDocoQuery.whereKey("to", equalTo: targetUser)
        userDocoQuery.whereKey("from", equalTo: PFUser.currentUser())
        targetCocoQuery.whereKey("to", equalTo: PFUser.currentUser())
        targetCocoQuery.whereKey("from", equalTo: targetUser)
        targetDocoQuery.whereKey("to", equalTo: PFUser.currentUser())
        targetDocoQuery.whereKey("from", equalTo: targetUser)
        
        var unitedCocoQuery = PFQuery.orQueryWithSubqueries([userCocoQuery, targetCocoQuery])
        //TODO: 使い勝手によってlimitを調節する
        unitedCocoQuery.limit = 20
        unitedCocoQuery.orderByDescending("createdAt")
        unitedCocoQuery.findObjectsInBackgroundWithBlock { (cocoObjects:[AnyObject]!, error :NSError!) -> Void in
            if error == nil{
                self.posts = cocoObjects as [PFObject]!
                self.cocoPosts = cocoObjects as [PFObject]!
                //MARK: - markerのMapViewへの設置
                for cocoObject :PFObject in cocoObjects as [PFObject]{
                    self.addMarkerofObject(cocoObject)
                }
                
                var unitedDocoQuery = PFQuery.orQueryWithSubqueries([userDocoQuery, targetDocoQuery])
                unitedDocoQuery.orderByDescending("createdAt")
                unitedDocoQuery.findObjectsInBackgroundWithBlock({ (docoObjects :[AnyObject]!, error:NSError!) -> Void in
                    if error == nil{
                        for docoObject in docoObjects{
                            self.posts.append(docoObject as PFObject)
                            var postsArray: NSMutableArray = NSMutableArray(array: self.posts)
                            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key:"createdAt", ascending:false)
                            let sorts = [sortDescriptor]
                            let sortedPosts = postsArray.sortedArrayUsingDescriptors(sorts)
                            self.posts = sortedPosts as [PFObject]
                            self.tableView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                        //MARK: - isCocoIndexへの値の追加
                        for post:PFObject in self.posts as [PFObject]{
                            var className = post.parseClassName
                            if className == "Coco"{
                                self.isCocoIndex.append(true)
                            }else{
                                self.isCocoIndex.append(false)
                            }
                        }
                    }else{
                        println("エラー")
                    }
                })
            }else{
                println("エラー")
            }
        }
    }
    
    //MARK: - markerのMapViewへの設置
    func addMarkerofObject(object:PFObject) {
        let point :PFGeoPoint = object.objectForKey("point") as PFGeoPoint
        let marker :GMSMarker = GMSMarker(position: CLLocationCoordinate2DMake(point.latitude, point.longitude))
        marker.snippet = formatter.stringFromDate(object.createdAt)
        self.markers.append(marker)
        println(marker.snippet)
        marker.map = self.mapView
        self.mapView?.animateToLocation(markers[0].position)
        self.mapView?.selectedMarker = markers[0]
    }
    
    //MARK: - 再読込
    func refresh() {
        println("リフレッシュ!")
        self.refreshActivityIndicator = UIActivityIndicatorView(frame: CGRectMake((self.refreshButton!.frame.width-self.refreshButton!.frame.height)/2, 0, self.refreshButton!.frame.height, self.refreshButton!.frame.height))
        self.refreshButton?.addSubview(refreshActivityIndicator)
        self.refreshActivityIndicator.startAnimating()
        
        if refreshControl.refreshing == false{
            self.refreshControl.beginRefreshing()
        }
        // MARK: - getPostメソッドのQueryにlastupdateの日付制限を加える
        lastUpdate = NSDate()
        //4つのqueryを作り、二つの統合queryを作る
        var userCocoQuery = PFQuery(className: "Coco")
        var userDocoQuery = PFQuery(className: "Doco")
        var targetCocoQuery = PFQuery(className: "Coco")
        var targetDocoQuery = PFQuery(className: "Doco")
        userCocoQuery.whereKey("to", equalTo: targetUser)
        userCocoQuery.whereKey("from", equalTo: PFUser.currentUser())
        userDocoQuery.whereKey("to", equalTo: targetUser)
        userDocoQuery.whereKey("from", equalTo: PFUser.currentUser())
        targetCocoQuery.whereKey("to", equalTo: PFUser.currentUser())
        targetCocoQuery.whereKey("from", equalTo: targetUser)
        targetDocoQuery.whereKey("to", equalTo: PFUser.currentUser())
        targetDocoQuery.whereKey("from", equalTo: targetUser)
        
        var unitedCocoQuery = PFQuery.orQueryWithSubqueries([userCocoQuery, targetCocoQuery])
        //TODO: 使い勝手によってlimitを調節する
        unitedCocoQuery.limit = 20
        unitedCocoQuery.whereKey("createdAt", lessThan: lastUpdate)
        unitedCocoQuery.orderByDescending("createdAt")
        unitedCocoQuery.findObjectsInBackgroundWithBlock { (cocoObjects:[AnyObject]!, error :NSError!) -> Void in
            if error == nil{
                println("cocoObjects:\(cocoObjects)")
                if cocoObjects.count != 0{
                self.posts = cocoObjects as [PFObject]!
                self.cocoPosts = cocoObjects as [PFObject]!
                self.refreshControl!.endRefreshing()
                //MARK: - markerのMapViewへの設置
                for cocoObject :PFObject in cocoObjects as [PFObject]{
                    self.addMarkerofObject(cocoObject)
                }
                }else{
                    println("CocoObjectが一つも見つかりませんでした")
                    self.refreshControl.endRefreshing()
                }
                var unitedDocoQuery = PFQuery.orQueryWithSubqueries([userDocoQuery, targetDocoQuery])
                unitedDocoQuery.orderByDescending("createdAt")
                //unitedDocoQuery.whereKey("createdAt", greaterThan: self.lastUpdate)
                unitedDocoQuery.whereKey("createdAt", lessThan: self.lastUpdate)
                unitedDocoQuery.findObjectsInBackgroundWithBlock({ (docoObjects :[AnyObject]!, error:NSError!) -> Void in
                    if error == nil{
                        if docoObjects.count != 0{
                        for docoObject in docoObjects{
                            self.posts.append(docoObject as PFObject)
                            var postsArray: NSMutableArray = NSMutableArray(array: self.posts)
                            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key:"createdAt", ascending:false)
                            let sorts = [sortDescriptor]
                            let sortedPosts = postsArray.sortedArrayUsingDescriptors(sorts)
                            self.posts = sortedPosts as [PFObject]
                            self.tableView.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.refreshControl!.endRefreshing()
                            self.refreshActivityIndicator.stopAnimating()
                        }
                        //MARK: - isCocoIndexへの値の追加
                        for post:PFObject in self.posts as [PFObject]{
                            var className = post.parseClassName
                            if className == "Coco"{
                                self.isCocoIndex.append(true)
                            }else{
                                self.isCocoIndex.append(false)
                            }
                        }
                    }else{
                        println("エラー")
                        self.refreshControl!.endRefreshing()
                        }
                    }else{
                        println("DocoObjectが一つも見つかりませんでした")
                        self.refreshControl.endRefreshing()
                    }
                })
            }else{
                println("エラー")
                self.refreshControl!.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view デリゲートメソッド
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(posts.count)
        return posts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 30))
        headerView.backgroundColor = UIColor.yellowColor()
        let titleLabel = UILabel(frame: CGRectMake(10, 0, 100, 30))
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
        titleLabel.tintColor = UIColor.whiteColor()
        headerView.addSubview(titleLabel)
        //MARK: - refreshButtonの設置
        self.refreshButton = UIButton(frame: CGRectMake(self.view.center.x-30, 0, 60.0, 40.0))
        self.refreshButton?.backgroundColor = UIColor.blueColor()
        self.refreshButton?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.TouchUpInside)
        self.tableView.addSubview(self.refreshButton!)
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("呼ばれた")
        //TODO: この時点でposts配列に最新の値が入っていないから間違った値が挿入される
        println(indexPath.row)
        var post = posts[indexPath.row]
        var className = post.parseClassName
        var fromUser = post.objectForKey("from") as PFUser
        
        if className == "Coco" && fromUser == PFUser.currentUser(){
            //ユーザーからターゲットに送ったCocoのPFObject
            let cell : UserCocoCell = tableView.dequeueReusableCellWithIdentifier("UserCocoCell") as UserCocoCell
            //MARK: - 住所の取得
            var point = post.objectForKey("point") as PFGeoPoint
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: point.latitude, longitude: point.longitude
                ), completionHandler: { (placemarks :[AnyObject]!, error :NSError!) -> Void in
                    if (error == nil && placemarks.count > 0) {
                        let placemark = placemarks[0] as CLPlacemark
                        let address = "\(placemark.administrativeArea)\(placemark.locality)\(placemark.subLocality)"
                        cell.addressLabel.text = address
                    }else{
                        println("住所取得の際にエラー発生")
                    }
            })
            
            cell.userImageView.image = currentUserImage
            cell.timeLabel.text = formatter.stringFromDate(post.createdAt)
            return cell
        }else if className == "Doco" && fromUser == PFUser.currentUser(){
            //ユーザーからターゲットに送ったDocoのPFObject
            let cell : UserDocoCell = tableView.dequeueReusableCellWithIdentifier("UserDocoCell") as UserDocoCell
            return cell
        }else if className == "Coco" && fromUser == targetUser{
            //ターゲットからユーザーに送ったCocoのPFObject
            let cell : TargetCocoCell = tableView.dequeueReusableCellWithIdentifier("TargetCocoCell") as TargetCocoCell
            var point = post.objectForKey("point") as PFGeoPoint
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: point.latitude, longitude: point.longitude
                ), completionHandler: { (placemarks :[AnyObject]!, error :NSError!) -> Void in
                    if (error == nil && placemarks.count > 0) {
                        let placemark = placemarks[0] as CLPlacemark
                        let address = "\(placemark.administrativeArea)\(placemark.locality)\(placemark.subLocality)"
                        cell.addressLabel.text = address
                    }else{
                        println("住所取得の際にエラー発生")
                    }
            })
            cell.userImageView.image = targetUserImage
            cell.timeLabel.text = formatter.stringFromDate(post.createdAt)
            return cell
        }
        else{
            //ターゲットからユーザーに送ったDocoのPFObject
            let cell : TargetDocoCell = tableView.dequeueReusableCellWithIdentifier("TargetDocoCell") as TargetDocoCell
            return cell
        }
    }
    //MARK: -　セルタップ時の挙動を設定
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isCocoIndex[indexPath.row]{
            let post = posts[indexPath.row]
            println(post)
            let index = find(self.cocoPosts, post)
            let point = post.objectForKey("point") as PFGeoPoint
            self.mapView?.animateToLocation(CLLocationCoordinate2DMake(point.latitude, point.longitude))
            self.mapView?.selectedMarker = self.markers[index!]
        }else{
            println("Docoのセルをタップされた")
        }
    }
    
    //MARK: - Docoオブジェクト、Cocoオブジェクトをテーブルとマップに新しく追加するメソッド。UsergaDocoやCocoボタンを押したり、新しく値を受け取った場合など。
    func docoAdded(doco:PFObject){
    }
    
    func cocoAdded(coco:PFObject){
    }
    
    //MARK: - 友達を削除するメソッド
    func deleteFriend(sender:AnyObject!){
        var alert = SCLAlertView()
        alert.addButton("友達から削除", target: self, selector: "deleteFriendConfirmed:")
        alert.showWarning("確認", subTitle: "本当に友達から削除しますか?", closeButtonTitle: "キャンセル", duration: 5.0)
    }
    
    func deleteFriendConfirmed(sender:AnyObject!){
        println("友達から削除決定")
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.removableUser = targetUser
        self.navigationController?.popViewControllerAnimated(true)
    }
}

