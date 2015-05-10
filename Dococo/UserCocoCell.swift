//
//  UserCocoCell.swift
//  Dococo
//
//  Created by 母利 睦人 on 2015/04/27.
//  Copyright (c) 2015年 Makoto Mori. All rights reserved.
//

import UIKit

class UserCocoCell: UITableViewCell {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.frame = CGRectMake(userImageView.frame.origin.x, userImageView.frame.origin.y, 50.0, 50.0)
        userImageView.layer.cornerRadius = self.userImageView.frame.width/2
        userImageView.clipsToBounds = true
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
