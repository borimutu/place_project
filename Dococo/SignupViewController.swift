//
//  SignupViewController.swift
//  
//
//  Created by 母利 睦人 on 2015/04/13.
//
//

import UIKit
import RMStepsController
import Parse

class SignupViewController: RMStepsController,UIImagePickerControllerDelegate {
    
    var controller1 :FirststepViewController?
    var controller2 :SecondstepViewController?
    var controller3 :ThirdstepViewController?
    var controller4 :FourthstepViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func stepViewControllers() -> [AnyObject]! {
        var controllerArray : [UIViewController] = []

        controller1 = self.storyboard?.instantiateViewControllerWithIdentifier("firststep") as? FirststepViewController
        controller1?.step.title = "アドレス"
        controllerArray.append(controller1!)
        /*
        controller2 = self.storyboard?.instantiateViewControllerWithIdentifier("secondstep") as? SecondstepViewController
        controllerArray.append(controller2!)
        */
        controller3 = self.storyboard?.instantiateViewControllerWithIdentifier("thirdstep") as? ThirdstepViewController
        controller3?.step.title = "プロフィール作成"
        controllerArray.append(controller3!)

        
        controller4 = self.storyboard?.instantiateViewControllerWithIdentifier("fourthstep") as? FourthstepViewController
        controller4?.step.title = "友達追加"
        controllerArray.append(controller4!)
        
        return controllerArray
    }
    
    override func canceled() {
        //登録中の項目があればアノテーションを出す
        //println(controller1?.textField?.text)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func finishedAllSteps() {
        println("Finished all steps")
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.isFromSignup = true
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
}
