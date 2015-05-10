//
//  SecondstepViewController.swift
//  
//
//  Created by 母利 睦人 on 2015/04/13.
//
//

import UIKit
import HTPressableButton
import IHKeyboardAvoiding
import JVFloatLabeledTextField
import TOMSMorphingLabel
import SCLAlertView
import Parse


class SecondstepViewController: UIViewController {
    var nextstepButton :HTPressableButton?
    var textField :JVFloatLabeledTextField?
    var recognizer :UIGestureRecognizer?
    var messageLabel :TOMSMorphingLabel?
    var previousstepButton :HTPressableButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel = TOMSMorphingLabel(frame: CGRectMake(0, 100, self.view.frame.width, 100))
        messageLabel?.morphingEnabled = true
        messageLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        messageLabel?.numberOfLines = 4
        messageLabel?.text = "入力されたメールアドレスにメールが届きます。メール認証を完了したら完了ボタンを押してくださいへ進んでください。"
        messageLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(messageLabel!)
        /*
        textField = JVFloatLabeledTextField(frame: CGRectMake(self.view.center.x-self.view.frame.size.width/2, self.view.frame.height/1.9, self.view.frame.size.width, 60))
        textField?.textAlignment = NSTextAlignment.Center
        textField?.setPlaceholder("verification code", floatingTitle: "verification code")
        textField?.keyboardType = UIKeyboardType.PhonePad
        self.view.addSubview(textField!)
        IHKeyboardAvoiding.setAvoidingView(self.view)
        
        recognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(recognizer!)*/
        
        nextstepButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100.0, self.view.frame.height/1.5 , 200, 50))
        nextstepButton?.style = HTPressableButtonStyle.Rounded
        nextstepButton?.buttonColor = UIColor.ht_aquaColor()
        nextstepButton?.setTitle("完了", forState: UIControlState.Normal)
        nextstepButton?.addTarget(self, action: "nextStep:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextstepButton!)
        
        /*
        previousstepButton = HTPressableButton(frame: CGRectMake(self.view.center.x-100.0, nextstepButton!.center.y+nextstepButton!.frame.height , 200, 50))
        previousstepButton?.style = HTPressableButtonStyle.Rounded
        previousstepButton?.buttonColor = UIColor.ht_aquaDarkColor()
        previousstepButton?.setTitle("Previous", forState: UIControlState.Normal)
        previousstepButton?.addTarget(self, action: "previousStep:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(previousstepButton!)*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func previousStep(button: HTPressableButton) {
        //self.stepsController.showPreviousStep()
    }

    func nextStep(button: HTPressableButton) {
        var isVerified:Bool = PFUser.currentUser().objectForKey("emailVerified") as Bool
        println(PFUser.currentUser().email)
        if isVerified{
            println("メール認証済み")
            self.stepsController.showNextStep()
        }else{
            println("メール認証が完了していません")
        }
    }
    
    func viewTapped(recognizer: UIGestureRecognizer) {
        println("tapped")
        textField?.resignFirstResponder()
    }
}
