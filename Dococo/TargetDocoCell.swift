//
//  TargetDocoCell.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/27.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit

class TargetDocoCell: UITableViewCell {
    var timeLabel: UILabel!
    var userImageView: UIImageView!
    var messageLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        //userImageView.layer.cornerRadius = userImageView.frame.height/2
        //userImageView.clipsToBounds = true
        //TODO:　デバイスの幅によって背景画像、種々ラベル、ユーザー画像の種類、位置を設定する
        var deviceWidth = UIScreen.mainScreen().bounds.width
        println(deviceWidth)
        if deviceWidth == 320{
            //MARK: - iPhone5のとき
            self.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground5")!)
        }else if deviceWidth == 375{
            //MARK: - iPhone6のとき
            println("iphone6")
            self.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground6")!)
        }else if deviceWidth == 414{
            //MARK: - iPhone6plusのとき
            self.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground6plus")!)
        }else{
            println("4S？")
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
