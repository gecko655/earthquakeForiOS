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
    @IBOutlet var dateLabel: UILabel!
    let dateFormat = DateFormatter()

    func reflect(_ status: Status){
        dateFormat.dateFormat = "yyyy MM/dd HH:mm:ss eee"
        dateFormat.timeZone = TimeZone.autoupdatingCurrent
        statusTextLabel.text = status.text
        screenNameLabel.text = "@\(status.user_screenname)"
        iconView.image = UIImage(data: status.icon as Data)
        if let created_at = status.created_at {
            dateLabel.text = dateFormat.string(from: created_at as Date)
        }else{
            dateLabel.removeFromSuperview()
        }
        if let media = status.media {
            mediaView.image = UIImage(data: media as Data)
        }else{
            mediaView.removeFromSuperview()
        }
    }
    
}
