//
//  MainViewController.swift
//  earthquakeForiOS
//
//  Created by akihiro on 2014/09/07.
//  Copyright (c) 2014年 gecko655. All rights reserved.
//

import Foundation
import UIKit
import SwifteriOS

class MainViewController: UITableViewController{
    
    var swifter: Swifter? = nil
    var statuses: [JSONValue]? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        swifter!.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: false, contributorDetails: false, includeEntities: true, success:{
                (statuses: [JSONValue]?) in
                self.statuses = statuses
            self.tableView.reloadData()
            }
            , failure: nil)
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if(self.statuses == nil){
            return 0
        }
        return self.statuses!.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let reuseIdentifier = "mainCell"
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = statuses![indexPath.row]["text"].string
        return cell
    }
}