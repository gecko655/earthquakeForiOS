//
//  Status.swift
//  earthquakeForiOS
//
//  Created by akihiro on 2014/09/13.
//  Copyright (c) 2014年 gecko655. All rights reserved.
//

import Foundation
import CoreData
import SwifteriOS

class Status: NSManagedObject {

    @NSManaged var created_at: NSDate
    @NSManaged var icon: NSData
    @NSManaged var id: NSNumber
    @NSManaged var text: String
    @NSManaged var user_name: String
    @NSManaged var user_screenname: String
    
    func setJSON(json: Dictionary<String,JSON>){
        id = json["id"]!.integer!
        text = json["text"]!.string!
    }

}
