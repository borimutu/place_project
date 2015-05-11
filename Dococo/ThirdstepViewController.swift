//
//  ThirdstepViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/14.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//
import UIKit
import HTPressableButton
import IHKeyboardAvoiding
import JVFloatLabeledTextField
import TOMSMorphingLabel
import SCLAlertView
import Parse


class ThirdstepViewController: UIImagePickerController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var nextstepButton :HTPressableButton?
    var recognizer :UIGestureRecognizer?
    var messageLabel :TOMSMorphingLabel?
    var previousstepButton :HTPressableButton?
    var nameField : JVFloatLabeledTextField?
    var userIdField : JVFloatLabeledTextField?
    var passField : JVFloatLabeledTextField?
    var passConfirmField : JVFloatLabeledTextField?
    var mailField : JVFloatLabeledTextField?
    var profileImageView :UIImageView?
    var profileImageButton :UIButton?
    var errorLabel :TOMSMorphingLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("次のステップへ")
        IHKeyboardAvoiding.setAvoidingView(self.view)
        messageLabel = TOMSMorphingLabel(frame: CGRectMake(0, 60, self.view.frame.width, 100))
        messageLabel?.morphingEnabled = true
        messageLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        messageLabel?.numberOfLines = 2
        messageLabel?.text = "プロフィールを作成しましょう"
        messageLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(messageLabel!)
        
        profileImageView = UIImageView(frame: CGRectMake(self.view.center.x-50, messageLabel!.center.y+50.0+10.0, 100, 100))
        profileImageView?.image = UIImage(named: "noimage.jpg")
        profileImageView?.layer.cornerRadius = 50.0
        profileImageView?.clipsToBounds = true
        self.view.addSubview(profileImageView!)
        
        //MARK: - profileImageView上にUIButtonを押してプロフィール画像を設定させる
        var profileChangeButton :UIButton = UIButton(frame: profileImageView!.frame)
        profileChangeButton.addTarget(self, action: "profileChange:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(profileChangeButton)
        
        nameField = JVFloatLabeledTextField(frame: CGRectMake(0, profileImageView!.center.y+130.0, self.view.frame.width, 40))
        nameField?.setPlaceholder("ユーザー名", floatingTitle: "ユーザー名")
        self.view.addSubview(nameField!)
        nameField?.autocorrectionType = UITextAutocorrectionType.No
        nameField?.autocapitalizationType = UITextAutocapitalizationType.None
        nameField?.textAlignment = NSTextAlignment.Center
        
        userIdField = JVFloatLabeledTextField(frame: CGRectMake(0, nameField!.center.y+40.0, self.view.frame.width, 40))
        userIdField?.setPlaceholder("ユーザーID", floatingTitle: "ユーザーID")
        userIdField?.autocorrectionType = UITextAutocorrectionType.No
        userIdField?.autocapitalizationType = UITextAutocapitalizationType.None
        self.view.addSubview(userIdField!)
        userIdField?.textAlignment = NSTextAlignment.Center
        
        recognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(recognizer!)
        
        nextstepButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100, self.userIdField!.frame.origin.y+50, 200, 50))
        nextstepButton?.style = HTPressableButtonStyle.Rounded
        nextstepButton?.buttonColor = UIColor.ht_aquaColor()
        nextstepButton?.setTitle("次へ", forState: UIControlState.Normal)
        nextstepButton?.addTarget(self, action: "nextStep:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextstepButton!)
        
        errorLabel = TOMSMorphingLabel(frame: CGRectMake(0, profileImageView!.frame.maxY+10.0, self.view.frame.width, 50))
        errorLabel?.morphingEnabled = true
        errorLabel?.textColor = UIColor.redColor()
        errorLabel?.numberOfLines = 2
        errorLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(errorLabel!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func previousStep(button: HTPressableButton) {
        self.stepsController.showPreviousStep()
    }
    
    func nextStep(button: HTPressableButton) {
        if self.nameField?.text == ""{
            errorLabel?.text = "ユーザー名の欄が空欄です"
        }else if self.userIdField?.text == ""{
            errorLabel?.text = "IDの欄が空欄です"
        }
        else{
        PFUser.currentUser()["name"] = self.nameField?.text
        PFUser.currentUser()["friends"] = []
        PFUser.currentUser()["keyword"] = self.userIdField?.text
        var picture = PFFile(data: UIImagePNGRepresentation(self.profileImageView?.image))
        PFUser.currentUser()["profilePicture"] = picture
        PFUser.currentUser().saveInBackgroundWithBlock { (succeeded:Bool, error:NSError!) -> Void in
            println("finished")
        }
            self.stepsController.showNextStep()
        }
    }
    
    func viewTapped(recognizer: UIGestureRecognizer) {
        println("tapped")
        nameField?.resignFirstResponder()
        userIdField?.resignFirstResponder()
        passField?.resignFirstResponder()
        passConfirmField?.resignFirstResponder()
        mailField?.resignFirstResponder()
        
    }
    
    func profileChange(button: UIButton){
        //MARK: - Actionsheetの呼び出し、ライブラリ・カメラからの写真の選択
        let alertController = UIAlertController(title: "プロフィール画像", message: "プロフィール画像の取得先を選択してください", preferredStyle: .ActionSheet)
        
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
        self.profileImageView?.image = image
        println("finished picking image")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        println("canceled")
    }
}
