//
//  FirststepViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/13.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import HTPressableButton
import JVFloatLabeledTextField
import TOMSMorphingLabel
import SCLAlertView
import Fabric
import TwitterKit
import Parse
import SCLAlertView
import TSMessages

class FirststepViewController: UIViewController {
    
    //var textField :JVFloatLabeledTextField?
    var recognizer :UIGestureRecognizer?
    var nextstepButton :HTPressableButton?
    var messageLabel :TOMSMorphingLabel?
    var errorLabel :TOMSMorphingLabel?
    var emailField: JVFloatLabeledTextField?
    var passwordField: JVFloatLabeledTextField?
    var passwordCheckField: JVFloatLabeledTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IHKeyboardAvoiding.setAvoidingView(self.view)
        
        /*digitsButton.frame = CGRectMake(self.view.center.x, self.view.center.y, 300, 50)
        self.view.addSubview(digitsButton)*/
        
        messageLabel = TOMSMorphingLabel(frame: CGRectMake(0, 100, self.view.frame.width, 100))
        messageLabel?.morphingEnabled = true
        messageLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        messageLabel?.numberOfLines = 2
        messageLabel?.text = "メールアドレスとパスワードを入力してください"
        messageLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(messageLabel!)
        
        errorLabel = TOMSMorphingLabel(frame: CGRectMake(0, messageLabel!.frame.origin.y+120, self.view.frame.width, 50))
        errorLabel?.morphingEnabled = true
        errorLabel?.textColor = UIColor.redColor()
        errorLabel?.numberOfLines = 2
        errorLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(errorLabel!)
        
        /*textField = JVFloatLabeledTextField(frame: CGRectMake(self.view.center.x-self.view.frame.size.width/2, self.view.frame.height/1.7, self.view.frame.size.width, 60))
        textField?.textAlignment = NSTextAlignment.Center
        textField?.setPlaceholder("Phonenumber", floatingTitle: "Phonenumber")
        //textField?.keyboardType = UIKeyboardType.PhonePad
        self.view.addSubview(textField!)*/
        
        emailField = JVFloatLabeledTextField(frame:  CGRectMake(self.view.center.x-self.view.frame.size.width/2, self.view.frame.height/2+40, self.view.frame.size.width, 40))
        emailField?.textAlignment = NSTextAlignment.Center
        emailField?.setPlaceholder("アドレス", floatingTitle: "アドレス")
        emailField?.autocorrectionType = UITextAutocorrectionType.No
        emailField?.autocapitalizationType = UITextAutocapitalizationType.None
        emailField?.keyboardType = UIKeyboardType.EmailAddress
        self.view.addSubview(emailField!)
        
        passwordField = JVFloatLabeledTextField(frame: CGRectMake(self.view.center.x-self.view.frame.size.width/2,emailField!.frame.origin.y+40, self.view.frame.size.width, 40))
        passwordField?.textAlignment = NSTextAlignment.Center
        passwordField?.autocapitalizationType = UITextAutocapitalizationType.None
        passwordField?.setPlaceholder("パスワード", floatingTitle: "パスワード")
        passwordField?.secureTextEntry = true
        self.view.addSubview(passwordField!)
        
        passwordCheckField = JVFloatLabeledTextField(frame: CGRectMake(self.view.center.x-self.view.frame.size.width/2,passwordField!.frame.origin.y+40, self.view.frame.size.width, 40))
        passwordCheckField?.textAlignment = NSTextAlignment.Center
        passwordCheckField?.autocapitalizationType = UITextAutocapitalizationType.None
        passwordCheckField?.setPlaceholder("パスワード確認", floatingTitle: "パスワード確認")
        passwordCheckField?.secureTextEntry = true
        self.view.addSubview(passwordCheckField!)
        
        recognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(recognizer!)
        
        nextstepButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100.0, passwordCheckField!.frame.origin.y+50 , 200, 50))
        nextstepButton?.style = HTPressableButtonStyle.Rounded
        nextstepButton?.buttonColor = UIColor.ht_aquaColor()
        nextstepButton?.setTitle("次のステップへ", forState: UIControlState.Normal)
        nextstepButton?.addTarget(self, action: "nextStep:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextstepButton!)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewTapped(sender: AnyObject) {
        println("tapped")
        self.emailField?.resignFirstResponder()
        self.passwordField?.resignFirstResponder()
        self.passwordCheckField?.resignFirstResponder()
    }
    
    func nextStep(button: HTPressableButton) {
        self.emailField?.resignFirstResponder()
        self.passwordField?.resignFirstResponder()
        self.passwordCheckField?.resignFirstResponder()
        
        if self.emailField?.text.utf16Count == 0 {
            errorLabel?.text = "メールアドレスの欄が空欄です"
            println("メールアドレスの欄が空欄です")
        }else if self.passwordField?.text.utf16Count == 0 {
            println("パスワードの欄がが空欄です")
            errorLabel?.text = "パスワードの欄が空欄です"

        }else if self.passwordCheckField?.text.utf16Count == 0 {
            println("パスワード確認欄が空欄です")
            errorLabel?.text = "パスワード確認欄が空欄です"

        }
        else if self.passwordField?.text != self.passwordCheckField?.text {
            errorLabel?.text = "入力されたパスワードが一致しません"
            println("入力されたパスワードが一致しません")
        }
        else{
            var user :PFUser = PFUser()
            user.username = self.emailField?.text
            user.password = self.passwordField?.text
            user.email = self.emailField?.text
            user.signUpInBackgroundWithBlock({ (succeeded: Bool, error:NSError!) -> Void in
                if error == nil{
                    println("新規登録成功")
                    self.errorLabel?.text = ""
                    self.messageLabel?.text = "おめでとうございます"
                    self.stepsController.showNextStep()
                }else{
                    //MARK: - エラー内容によってerrorLabelの文言を変える
                    if error.code == 125{
                        self.errorLabel?.text = "無効なメールアドレスです"
                    }else if error.code == 202 {
                        self.errorLabel?.text = "このメールアドレスはすでに使われています"
                    }else{
                        self.errorLabel?.text = "通信エラーです"
                    }
                    
                }
            })
        }
    }
    
    func didTapButton(sender: AnyObject) {

    }
}
