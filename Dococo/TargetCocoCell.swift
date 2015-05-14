//
//  TargetCocoCell.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/25.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit

class TargetCocoCell: UITableViewCell {
    var timeLabel: UILabel!
    var userImageView: UIImageView!
    var messageLabel: UILabel?
    var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //選択された時のbackgroundViewを設定

        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        //TODO:　デバイスの幅によって背景画像、種々ラベル、ユーザー画像の種類、位置を設定する
        var deviceWidth = UIScreen.mainScreen().bounds.width
        //5のとき
        if deviceWidth == 320{
            self.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground5")!)
            /*var selectedBackgroundView = UIView(frame: self.frame)
            selectedBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground5selected")!)
            self.selectedBackgroundView = selectedBackgroundView*/
            
        }else if deviceWidth == 375{
            self.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground6")!)
            /*var selectedBackgroundView = UIView(frame: self.frame)
            selectedBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground6selected")!)
            self.selectedBackgroundView = selectedBackgroundView*/

        }else if deviceWidth == 414{
            self.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground6plus")!)
            /*var selectedBackgroundView = UIView(frame: self.frame)
            selectedBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "targetcellbackground6plusselected")!)
            self.selectedBackgroundView = selectedBackgroundView*/
        }else{
            println("4S？")
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
