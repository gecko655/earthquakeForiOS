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
    @NSManaged var text: String
    @NSManaged var user_name: String
    @NSManaged var user_screenname: String
    
    class func getStatus(json: Dictionary<String,JSON>) -> Status{
        let appDel = UIApplication.sharedApplication().delegate! as AppDelegate
        let context = appDel.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Status", inManagedObjectContext: context)
        let status = Status(entity: entity!, insertIntoManagedObjectContext: nil)
        status.setJSON(json)
        return status
    }
    func setJSON(json: Dictionary<String,JSON>){
        id = json["id"]!.integer!
        text = json["text"]!.string!
        user_screenname = json["user"]!["screen_name"].string!
    }

}
