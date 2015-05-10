//
//  ProfileViewController.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/22.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    
    var nameLabel :UILabel?
    var userImageView : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - プロフィール画像の取得
        var userImage: UIImage?
        var userImageFile: PFFile = PFUser.currentUser()!.objectForKey("profilePicture") as PFFile
        userImageFile.getDataInBackgroundWithBlock { (imageData:NSData!, error:NSError!) -> Void in
            userImage = UIImage(data: imageData!)
            //MARK: - UserImageViewの設置
            self.userImageView = UIImageView(frame: CGRectMake(self.view.center.x-45, self.view.center.y-90, 90, 90))
            self.userImageView?.layer.cornerRadius =  self.userImageView!.frame.width/2
            self.userImageView?.clipsToBounds = true
            self.userImageView?.image = userImage
            self.view.addSubview(self.userImageView!)
        }
        
        //MARK: -ユーザー名ラベルの設置
        self.nameLabel = UILabel(frame: CGRectMake(0, self.view.center.y, self.view.frame.width, 30))
        self.nameLabel?.text = PFUser.currentUser()!.objectForKey("name") as? String
        self.nameLabel?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.nameLabel!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
