//
//  ProfileViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/22.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import Parse
import IHKeyboardAvoiding

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var nameLabel :UILabel?
    var userImageView : UIImageView?
    var userImageChangeButton : UIButton?
    var userNameChangeButton : UIButton?
    var userNameChangeField : UITextField?
    var recognizer :UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - プロフィール画像の取得
        var userImage: UIImage?
        var userImageFile: PFFile = PFUser.currentUser()!.objectForKey("profilePicture") as PFFile
        userImageFile.getDataInBackgroundWithBlock { (imageData:NSData!, error:NSError!) -> Void in
            userImage = UIImage(data: imageData!)
            //MARK: - UserImageViewの設置
            self.userImageView = UIImageView(frame: CGRectMake(self.view.center.x-45, 20, 90, 90))
            self.userImageView?.layer.cornerRadius =  self.userImageView!.frame.width/2
            self.userImageView?.clipsToBounds = true
            self.userImageView?.image = userImage
            self.view.addSubview(self.userImageView!)
            self.userImageChangeButton = UIButton(frame: CGRectMake(self.view.center.x-60, self.userImageView!.frame.maxY+10.0, 120, 30))
            self.userImageChangeButton?.backgroundColor = UIColor.blackColor()
            self.userImageChangeButton?.setTitle("画像変更", forState: UIControlState.Normal)
            self.userImageChangeButton?.addTarget(self, action: "changeUserImage", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(self.userImageChangeButton!)
        }
        
        //MARK: -ユーザー名ラベルの設置
        self.nameLabel = UILabel(frame: CGRectMake(0, self.view.center.y, self.view.frame.width, 30))
        self.nameLabel?.text = PFUser.currentUser()!.objectForKey("name") as? String
        self.nameLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.nameLabel!)
        
        userNameChangeButton = UIButton(frame: CGRectMake(self.view.center.x-60, self.nameLabel!.frame.maxY+10.0, 120, 30))
        userNameChangeButton?.backgroundColor = UIColor.blackColor()
        userNameChangeButton?.setTitle("名前変更", forState: UIControlState.Normal)
        userNameChangeButton?.addTarget(self, action: "changeUserName", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(userNameChangeButton!)
        
        recognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(recognizer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        IHKeyboardAvoiding.setAvoidingView(self.view)
    }
    
    func changeUserName(){
        userNameChangeField?.resignFirstResponder()
        if userNameChangeButton?.titleLabel?.text == "名前変更"{
            self.userNameChangeField = UITextField(frame: self.nameLabel!.frame)
            self.userNameChangeField?.backgroundColor = UIColor.lightGrayColor()
            self.userNameChangeField?.textAlignment = NSTextAlignment.Center
            self.userNameChangeField?.autocorrectionType = UITextAutocorrectionType.No
            self.userNameChangeField?.autocapitalizationType = UITextAutocapitalizationType.None
            self.view.addSubview(self.userNameChangeField!)
            self.userNameChangeButton?.setTitle("名前変更完了", forState: UIControlState.Normal)
            self.userNameChangeField?.selected = true
            self.nameLabel?.hidden = true
        }else{
            self.userNameChangeField?.removeFromSuperview()
            self.userNameChangeButton?.setTitle("名前変更", forState: UIControlState.Normal)
            PFUser.currentUser()["name"] = self.userNameChangeField?.text
            PFUser.currentUser().saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
                if error == nil{
                    println("名前変更成功")
                    self.nameLabel?.text = self.userNameChangeField?.text
                    self.nameLabel?.hidden = false
                    self.userNameChangeField?.hidden = true
                }else{
                    println("名前変更失敗")
                }
            })
        }
    }
    
    func changeUserImage(){
        println("画像変更")
        userNameChangeField?.resignFirstResponder()
        //MARK: - Actionsheetの呼び出し、ライブラリ・カメラからの写真の選択
        let alertController = UIAlertController(title: "プロフィール画像", message: "", preferredStyle: .ActionSheet)
        
        let libraryAction = UIAlertAction(title: "フォトライブラリ", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                UIAlertView(title: "警告", message: "Photoライブラリにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
            } else {
                var imagePickerController = UIImagePickerController()
                
                // フォトライブラリから選択
                imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                // 編集OFFに設定
                // これをtrueにすると写真選択時、写真編集画面に移る
                imagePickerController.allowsEditing = true
                
                // デリゲート設定
                imagePickerController.delegate = self
                
                // 選択画面起動
                self.presentViewController(imagePickerController,animated:true ,completion:nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                UIAlertView(title: "警告", message: "カメラにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
            } else {
                var imagePickerController = UIImagePickerController()
                
                // フォトライブラリから選択
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                
                // 編集OFFに設定
                // これをtrueにすると写真選択時、写真編集画面に移る
                imagePickerController.allowsEditing = true
                
                // デリゲート設定
                imagePickerController.delegate = self
                
                // 選択画面起動
                self.presentViewController(imagePickerController,animated:true ,completion:nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.userImageView?.image = image
        println("finished picking image")
        self.dismissViewControllerAnimated(true, completion: nil)
        var picture = PFFile(data: UIImagePNGRepresentation(self.userImageView?.image))
        PFUser.currentUser()["profilePicture"] = picture
        PFUser.currentUser().saveInBackgroundWithBlock { (succeeded:Bool, error:NSError!) -> Void in
            if error == nil{
                println("finished")
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        println("canceled")
    }

    func viewTapped(recognizer: UIGestureRecognizer) {
        userNameChangeField?.resignFirstResponder()
    }
}
