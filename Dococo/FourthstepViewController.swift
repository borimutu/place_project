//
//  FourthstepViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/14.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import HTPressableButton
import Parse
import TOMSMorphingLabel
import SCLAlertView

class FourthstepViewController: UIViewController,UISearchBarDelegate {
    var nextstepButton :HTPressableButton?
    var messageLabel :TOMSMorphingLabel?
    var searchBar :UISearchBar?
    var recognizer :UITapGestureRecognizer?
    var userimageView : UIImageView?
    var usernameLabel : UILabel?
    var addfriendButton : HTPressableButton?
    var addedFriend : PFUser?
    var friendsArray : [PFUser]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel = TOMSMorphingLabel(frame: CGRectMake(0, 60, self.view.frame.width, 100))
        messageLabel?.morphingEnabled = true
        messageLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        messageLabel?.numberOfLines = 2
        messageLabel?.text = "友達のIDがわかる場合は入力してください"
        messageLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(messageLabel!)
        
        searchBar = UISearchBar(frame: CGRectMake(0, messageLabel!.frame.origin.y+100+20, self.view.frame.width, 40))
        searchBar?.delegate = self
        searchBar?.placeholder = "Dococo ID"
        searchBar?.autocorrectionType = UITextAutocorrectionType.No
        searchBar?.autocapitalizationType = UITextAutocapitalizationType.None
        self.view.addSubview(searchBar!)
        
        recognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(recognizer!)
        
        userimageView = UIImageView(frame: CGRectMake(self.view.center.x-40.0, searchBar!.center.y+80.0, 80.0, 80.0))
        self.view.addSubview(userimageView!)
        userimageView?.layer.cornerRadius = 40.0
        userimageView?.clipsToBounds = true
        
        usernameLabel = UILabel(frame: CGRectMake(0, userimageView!.center.y+50.0, self.view.frame.width, 40))
        usernameLabel?.textAlignment = NSTextAlignment.Center
        usernameLabel?.textColor = UIColor.whiteColor()
        self.view.addSubview(usernameLabel!)
        
        addfriendButton = HTPressableButton(frame: CGRectMake(self.view.center.x-50.0, usernameLabel!.center.y+30.0, 100.0, 40.0))
        addfriendButton?.backgroundColor = UIColor.ht_aquaColor()
        addfriendButton?.setTitle("Add friend", forState: UIControlState.Normal)
        addfriendButton?.addTarget(self, action: "addfriendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        nextstepButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100.0, addfriendButton!.frame.maxY+20.0 , 200, 50))
        nextstepButton?.style = HTPressableButtonStyle.Rounded
        nextstepButton?.buttonColor = UIColor.ht_aquaColor()
        nextstepButton?.setTitle("完了", forState: UIControlState.Normal)
        nextstepButton?.addTarget(self, action: "nextStep:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextstepButton!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func nextStep(button: HTPressableButton) {
        self.stepsController.showNextStep()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        println(PFUser.currentUser().objectForKey("name"))
        var userName = PFUser.currentUser().username
        var password = PFUser.currentUser().password
        PFUser.logInWithUsername(userName, password: password)
        self.userimageView?.image = nil
        let keyword : NSString! = searchBar.text
        var query: PFQuery = PFUser.query()
        query.whereKey("keyword", equalTo: keyword)
        query.findObjectsInBackgroundWithBlock { (objects :[AnyObject]!, error :NSError!) -> Void in
            if (error == nil && objects.count != 0){
                var user :PFUser! = objects[0] as PFUser
                self.usernameLabel?.text = user.objectForKey("name") as NSString!
                self.addedFriend = user
                self.view.addSubview(self.addfriendButton!)
                var imageFile :PFFile! = user.objectForKey("profilePicture") as PFFile
                imageFile.getDataInBackgroundWithBlock({ (imageData : NSData!, error :NSError!) -> Void in
                    if (error == nil){
                        var image = UIImage(data: imageData)
                        self.userimageView?.image = image!
                    }else{
                    }
                })
            }else{
                println(error)
                println("There is no user using this keyword")
            }
        }
    }
    
    func viewTapped(recognizer :UITapGestureRecognizer){
        searchBar?.resignFirstResponder()
    }
    
    func addfriendButtonTapped(button: UIButton){
        //友達検索、表示機能
        friendsArray = PFUser.currentUser().objectForKey("friends") as? [PFUser]
        friendsArray!.append(addedFriend!)
        PFUser.currentUser()["friends"] = friendsArray as [PFUser]!
        PFUser.currentUser().saveInBackgroundWithBlock { (succeeded :Bool!, error :NSError!) -> Void in
            if (error == nil){
                println("succeeded")
                SCLAlertView().showSuccess("完了", subTitle: "友達を追加しました", closeButtonTitle: "OK", duration: 5.0)
            }else{
                println("failed")
            }
        }
    }
}
