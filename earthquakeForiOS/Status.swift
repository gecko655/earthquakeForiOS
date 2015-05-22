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

    @NSManaged var created_at: NSDate
    @NSManaged var icon: NSData
    @NSManaged var id: NSNumber
    @NSManaged var id_str: String
    @NSManaged var text: String
    @NSManaged var user_name: String
    @NSManaged var user_screenname: String
    @NSManaged var media: NSData?
    
    var statusJSON:Dictionary<String,JSON>?
    
    class func getStatus(json: Dictionary<String,JSON>) -> Status{
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Status", inManagedObjectContext: context)
        let status = Status(entity: entity!, insertIntoManagedObjectContext: nil)
        status.setJSON(json)
        return status
    }
    func setJSON(json: Dictionary<String,JSON>){
        statusJSON = json
        //id = json["id"]!.integer!
        id_str = json["id_str"]!.string!
        text = json["text"]!.string!
        user_screenname = json["user"]!["screen_name"].string!
        if json["entities"]?["media"][0]["type"].string == "photo" {
            if let media_url = json["entities"]!["media"][0]["media_url"].string {
                media = NSData(contentsOfURL: NSURL(string: media_url)!, options: nil, error: nil)
            }
        }
        if let profile_image_url = json["user"]?["profile_image_url_https"].string{
            icon = NSData(contentsOfURL: NSURL(string: profile_image_url)!, options: nil, error: nil)!
        }
    }
}
