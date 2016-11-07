//
//  Status.swift
//  earthquakeForiOS
//
//  Created by akihiro on 2014/09/13.
//  Copyright (c) 2014年 gecko655. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwifteriOS

class Status: NSManagedObject {

    @NSManaged var created_at: Date?
    @NSManaged var icon: Data
    @NSManaged var id: NSNumber
    @NSManaged var id_str: String
    @NSManaged var text: String
    @NSManaged var user_name: String
    @NSManaged var user_screenname: String
    @NSManaged var media: Data?
    
    var statusJSON: JSON?
    
    class func getStatus(_ json: JSON) -> Status{
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        let entity = NSEntityDescription.entity(forEntityName: "Status", in: context)
        let status = Status(entity: entity!, insertInto: nil)
        status.setJSON(json)
        return status
    }
    func setJSON(_ json: JSON){
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        statusJSON = json
        //id = json["id"]!.integer!
        id_str = json["id_str"].string!
        text = json["text"].string!
        user_screenname = json["user"]["screen_name"].string!
        if json["entities"]["media"][0]["type"].string == "photo" {
            if let media_url = json["entities"]["media"][0]["media_url"].string {
                media = try? Data.init(contentsOf: URL(string: media_url)!)
            }
        }
        if let profile_image_url = json["user"]["profile_image_url_https"].string{
            icon = try! Data.init(contentsOf: URL(string: profile_image_url)!)
        }
        created_at = dateFormat.date(from: json["created_at"].string!)
    }
}
