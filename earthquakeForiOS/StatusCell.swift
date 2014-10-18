//
//  StatusCell.swift
//  earthquakeForiOS
//
//  Created by akihiro on 2014/09/07.
//  Copyright (c) 2014年 gecko655. All rights reserved.
//

import Foundation
import UIKit
import SwifteriOS

class StatusCell: UITableViewCell{
    @IBOutlet var statusTextLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var mediaView: UIImageView!
    @IBOutlet var iconView: UIImageView!
    
    func reflect(status: Status){
        statusTextLabel.text = status.text
        screenNameLabel.text = "@\(status.user_screenname)"
        iconView.image = UIImage(data: status.icon)
        if (status.media == nil){
            mediaView.hidden = true
            mediaView.sizeToFit()
        }else{
            mediaView.hidden = false
            mediaView.image = UIImage(data: status.media!)
        }
    }
    
}
