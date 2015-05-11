//
//  AddFriendViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/20.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import Parse
import HTPressableButton
import SCLAlertView

class AddFriendViewController: UIViewController,UISearchBarDelegate {

    var searchBar :UISearchBar?
    var recognizer :UITapGestureRecognizer?
    var userimageView : UIImageView?
    var usernameLabel : UILabel?
    var addfriendButton : HTPressableButton?
    var addedFriend : PFUser?
    var friendsArray : [PFUser]? = []
    var id : AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.view.frame.width, 40))
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
        
        let idLabel = UILabel(frame: CGRectMake(0, self.searchBar!.center.y+40.0, self.view.frame.width, 40.0))
        id = PFUser.currentUser().objectForKey("keyword")
        idLabel.textAlignment = NSTextAlignment.Center
        idLabel.text = "自分のID : \(id)"
        self.view.addSubview(idLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar.text
        var idsList :[String]! = []
        let friendsList: [PFUser]! = PFUser.currentUser().objectForKey("friends") as [PFUser]
        for friend in friendsList{
            idsList.append(friend.objectForKey("keyword") as String)
        }
        if searchText == id as String{
            SCLAlertView().showError("エラー", subTitle: "自分のIDが入力されました", closeButtonTitle: "OK", duration: 5.0)
        }else if contains(idsList, searchText){
            SCLAlertView().showError("エラー", subTitle: "すでに友達になっています", closeButtonTitle: "OK", duration: 5.0)
        }else{
        println("search button clicked")
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
                println("There is no user using this keyword")
            }
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
