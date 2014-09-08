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
    var statuses: [Dictionary<String,JSONValue>]? = []
    
    
    @IBOutlet var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        swifter!.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: false, contributorDetails: false, includeEntities: true, success:{
                (statuses: [JSONValue]?) in
                self.statuses = statuses
            self.tableView.reloadData()
            }
            , failure: nil)
        */
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.statuses == nil){
            return 0
        }
        return self.statuses!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "mainCell"
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = statuses![indexPath.row]["text"]!.string
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let status = statuses![indexPath.row]
        let failureHandler: ((NSError) -> Void) = {
            error in

            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        swifter?.postStatusRetweetWithID(status["id"]!.integer!, trimUser: false, success: {
            status in
            let text = "text"
            let user = "user"
            let screen_name = "screen_name"
            self.alertWithTitle("Retweeted", message: "Retweeted the tweet: \(status![text]) by \(status![user]![screen_name].string!)")
        }, failure: failureHandler)
    }
    @IBAction func urlButtonClicked(sender: AnyObject, forEvent event: UIEvent) {
        fetchStatus(self.urlTextField.text)
    }
    
    func fetchStatus(url: String){
        let pattern = "https://twitter.com/[^/]*/status.*/(\\d{1,20})";
        let regex: NSRegularExpression = NSRegularExpression.regularExpressionWithPattern(pattern, options: nil, error: nil)!
        let resultRange = regex.firstMatchInString(url, options: nil, range: NSMakeRange(0, countElements(url)))!.rangeAtIndex(1).toRange()
        let statusId = url[resultRange!].toInt()
        let failureHandler: ((NSError) -> Void) = {
            error in

            self.alertWithTitle("Error", message: error.localizedDescription)
        }

        if(statusId != nil){
        
        swifter?.getStatusesShowWithID(statusId!, count: 1, trimUser: false, includeMyRetweet: false, includeEntities: true, success:
            {status in
                self.statuses!.append(status!)
                self.tableView.reloadData()
            }
            , failure: failureHandler)

      }
    }
    
    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
extension String
{
    subscript(integerIndex: Int) -> Character
    {
        let index = advance(startIndex, integerIndex)
            return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String
    {
        let start = advance(startIndex, integerRange.startIndex)
        let end = advance(startIndex, integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
}