//
//  LoginViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/12.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import Parse
import pop
import HTPressableButton
import JVFloatLabeledTextField
import IHKeyboardAvoiding
import SCLAlertView
import TOMSMorphingLabel
import Canvas

class LoginViewController: UIViewController, UIScrollViewDelegate {
    var phonenumberField: JVFloatLabeledTextField?
    var passwordField: JVFloatLabeledTextField?
    var passwordForgattenButton : HTPressableButton?
    var loginButton :HTPressableButton?
    var signupButton: HTPressableButton?
    var recognizer :UIGestureRecognizer?
    var logoView :UIImageView?
    var isFromSignup :Bool!
    var errorLabel :TOMSMorphingLabel?
    var loginAnimationView :CSAnimationView?
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("login")
        // Do any additional setup after loading the view.
        //微妙にスクロールビューの大きさを下のビューよりも大きくしている
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.001)
        scrollView.pagingEnabled = true // ページするオプションを有効にするための設定
        scrollView.scrollEnabled = true
        scrollView.directionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        signupButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100.0, self.view.frame.height/1.3 , 200, 50))
        signupButton?.setTitle("新規登録", forState: UIControlState.Normal)
        signupButton?.addTarget(self, action: "signUp:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(signupButton!)
        
        recognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(recognizer!)
        
        phonenumberField = JVFloatLabeledTextField(frame:  CGRectMake(0, self.view.frame.height/2.3+30.0, self.view.frame.size.width, 40))
        phonenumberField?.textAlignment = NSTextAlignment.Center
        phonenumberField?.autocorrectionType = UITextAutocorrectionType.No
        phonenumberField?.autocapitalizationType = UITextAutocapitalizationType.None
        phonenumberField?.setPlaceholder("メールアドレス", floatingTitle: "メールアドレス")
        phonenumberField?.keyboardType = UIKeyboardType.EmailAddress
        self.scrollView.addSubview(phonenumberField!)
        
        passwordField = JVFloatLabeledTextField(frame: CGRectMake(self.view.center.x-self.view.frame.size.width/2,phonenumberField!.frame.origin.y+40, self.view.frame.size.width, 40))
        passwordField?.textAlignment = NSTextAlignment.Center
        passwordField?.autocorrectionType = UITextAutocorrectionType.No
        passwordField?.autocapitalizationType = UITextAutocapitalizationType.None
        passwordField?.setPlaceholder("パスワード", floatingTitle: "パスワード")
        passwordField?.secureTextEntry = true
        self.scrollView.addSubview(passwordField!)
        
        loginAnimationView = CSAnimationView(frame: CGRectMake(100, 100, 100, 100))
        loginAnimationView?.backgroundColor = UIColor.redColor()
        //loginAnimationView!.type = CSAnimationTypeFadeInLeft
        loginAnimationView!.duration = 0.5
        loginAnimationView!.delay = 0
        self.scrollView.addSubview(loginAnimationView!)
        loginAnimationView!.startCanvasAnimation()
        
        loginButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100.0, self.signupButton!.frame.origin.y-60.0, 200, 50))
        loginButton?.setTitle("ログイン", forState: UIControlState.Normal)
        loginButton?.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(loginButton!)
        
        errorLabel = TOMSMorphingLabel(frame: CGRectMake(0, phonenumberField!.frame.origin.y-60, self.view.frame.width, 50))
        errorLabel?.morphingEnabled = true
        errorLabel?.textColor = UIColor.redColor()
        errorLabel?.numberOfLines = 2
        errorLabel?.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(errorLabel!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        IHKeyboardAvoiding.setAvoidingView(self.view)
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        isFromSignup = appDelegate.isFromSignup
        if isFromSignup == nil{
        }else{
        if isFromSignup == true {
            self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func viewTapped(recognizer: UIGestureRecognizer) {
        phonenumberField?.resignFirstResponder()
        passwordField?.resignFirstResponder()
    }
    
     func signUp(button: UIButton) {
        phonenumberField?.resignFirstResponder()
        passwordField?.resignFirstResponder()
        self.performSegueWithIdentifier("signup", sender: nil)
    }
    
    func login(button: UIButton) {
        phonenumberField?.resignFirstResponder()
        passwordField?.resignFirstResponder()
        PFUser.logInWithUsernameInBackground(phonenumberField?.text, password: passwordField?.text) { (user :PFUser! , error :NSError!) -> Void in
            if (error == nil){
                println("Success")
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                self.errorLabel?.text = "ログインに失敗しました"
                println(error)
            }
        }
    }
    
}
