//
//  TimelineViewController.swift
//  
//
//  Created by 母利 睦人 on 2015/04/13.
//
//

import UIKit
import MapKit
import CoreLocation
import HTPressableButton
import Parse


class TimelineViewController: UIViewController ,GMSMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate,UITableViewDataSource {
    
    var parentNavigationController : UINavigationController?
    var mapView: GMSMapView?
    var locationManager : CLLocationManager?
    var CocoButton : HTPressableButton?
    var friends :[PFUser]? = []
    var markers : [GMSMarker] = []
    var sentDates : [String] = []
    @IBOutlet var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    var refreshControl:UIRefreshControl!
    var lastUpdate : NSDate?
    var posts : [PFObject]? = []
    var formatter :NSDateFormatter = NSDateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - フレンドリストの取得
        self.friends = PFUser.currentUser()!.objectForKey("friends") as? [PFUser]
        
        //MARK: - MapViewの設置
        let navBarHeight:CGFloat? = self.parentNavigationController?.navigationBar.frame.size.height
        let statusBarHeight: CGFloat? = UIApplication.sharedApplication().statusBarFrame.height
        mapView = GMSMapView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height/2.5))
        mapView?.myLocationEnabled = true
        self.view?.addSubview(mapView!)
        mapView?.animateToLocation(CLLocationCoordinate2DMake(35.65858, 139.745433))
        
        //MARK: - locationmanagerの設置
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        
        //MARK: - formatter初期化
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        //MARK: - Cocoボタンの設置
        var cocoX : CGFloat = self.view.frame.width - 70.0
        var cocoY = mapView!.frame.height - 70.0
        
        CocoButton = HTPressableButton(frame: CGRectMake(cocoX, cocoY, 60, 60), buttonStyle: HTPressableButtonStyle.Circular)
        CocoButton?.buttonColor = UIColor.ht_grapeFruitColor()
        CocoButton?.shadowColor = UIColor.ht_grapeFruitDarkColor()
        CocoButton?.setTitle("Coco", forState: UIControlState.Normal)
        CocoButton?.addTarget(self, action:"cocobuttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(CocoButton!)
        
        //MARK: - tableview設置
        tableView = UITableView(frame: CGRectMake(0, self.mapView!.frame.height, self.view.frame.size.width, self.view.frame.height-self.view.frame.height/2.5-65), style: UITableViewStyle.Grouped)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.registerNib(UINib(nibName: "TargetCocoCell", bundle: nil), forCellReuseIdentifier: "TargetCocoCell")

        //MARK: - activityindicatorを表示
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.center.x-30, self.tableView.center.y-30, 60, 60))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        //MARK: - refreshcontrolの追加
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "getPoint", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        //MARK: - 投稿の取得、描画
        self.getPosts()
    }
    
    //MARK: - 現在地情報取得成功、マップ移動
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:newLocation.coordinate.latitude,longitude:newLocation.coordinate.longitude)
        var currentLocationCamera :GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude,longitude:coordinate.longitude,zoom:17)
        mapView?.camera = currentLocationCamera
        locationManager?.stopUpdatingLocation()
    }
    
    //MARK: - Cocoボタンタップ時の挙動設定
    func cocobuttonTapped(button: UIButton) {
        var object :PFObject = PFObject(className: "FriendsCoco")
        object["to"] = friends
        object["from"] = PFUser.currentUser()
        PFGeoPoint.geoPointForCurrentLocationInBackground { (point :PFGeoPoint?, error :NSError?) -> Void in
            if (error == nil){
                object["point"] = point
                object.saveInBackgroundWithBlock({ (succeeded :Bool, error :NSError?) -> Void in
                    if (error == nil){
                        var marker:GMSMarker? = GMSMarker()
                        marker?.position = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
                        marker?.snippet = self.formatter.stringFromDate(object.createdAt!)
                        marker?.appearAnimation = kGMSMarkerAnimationPop
                        marker?.map = self.mapView
                        self.mapView?.animateToLocation(marker!.position)
                        /*
                        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: point.latitude, longitude: point.longitude
                            ), completionHandler: { (object :[AnyObject]!, error :NSError!) -> Void in
                                if (error == nil){
                                    println(object)
                                }else{
                                    println("an error occured")
                                }
                        })*/
                    }else{
                    }
                })
            }
        }
    }
    
    func getPosts() {
        var query :PFQuery = PFQuery(className: "FriendsCoco")
        query.limit = 50
        
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        println("検索準備開始")
        query.findObjectsInBackgroundWithBlock { (objects :[AnyObject]?, error :NSError?) -> Void in
            if error == nil{
                if objects!.count == 0{
                    println("検索結果0件")
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                }else{
                    println(objects?.count)
                    println("エラー無し")
                    for object :PFObject! in objects as [PFObject]{
                        self.posts?.append(object)
                        /*
                        var marker:GMSMarker? = GMSMarker()
                        marker?.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
                        marker?.snippet = self.formatter.stringFromDate(object!.createdAt)
                        marker?.appearAnimation = kGMSMarkerAnimationPop
                        marker?.map = self.mapView
                        self.markers.append(marker!)
                        self.mapView?.animateToLocation(CLLocationCoordinate2DMake(point.latitude, point.longitude))*/
                        
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }else{
                println("エラー発生")
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - テーブルビューdatasourceメソッド
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("number of rows")
        if self.posts?.count == 0{
        return 0
        }else{
        return self.posts!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("cell for row at index")
        let cell : TargetCocoCell = tableView.dequeueReusableCellWithIdentifier("TargetCocoCell") as TargetCocoCell
        println(indexPath.row)
        var num = indexPath.row
        var post = self.posts![num]
        
        //var post: PFObject = self.posts![indexPath.row]
        //var postUser :PFUser? = post.objectForKey("from") as? PFUser
        //var username: AnyObject? = postUser?.objectForKey("name")
        //println("\(username)")
        //cell.addressLabel.text = postUser!.objectForKey("name") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let marker = self.markers[indexPath.row]
        self.mapView?.animateToLocation(marker.position)
        self.mapView?.selectedMarker = marker
    }
    
}
