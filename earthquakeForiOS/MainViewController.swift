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
import CoreData

class MainViewController: UITableViewController{
    
    var swifter: Swifter? = nil
    var statuses: [Status] = []
    
    
    @IBOutlet var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statusesLoad = loadStatuses()
        for status in statusesLoad{
            statuses.append(status)
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "mainCell"
        let cell: StatusCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as StatusCell
        cell.reflect(statuses[indexPath.row])
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let status = statuses[indexPath.row]
        let failureHandler: ((NSError) -> Void) = {
            error in

            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        swifter!.getStatusesShowWithID(status.id, count: 1, trimUser: false, includeMyRetweet: true, includeEntities: false, success: {
            jsonFetched in
            if(jsonFetched!["retweeted"]!.integer! != 0){
                let id = jsonFetched!["current_user_retweet"]!["id"].integer!
                self.swifter!.postStatusesDestroyWithID(id, trimUser: false, success:{
                    json in
                    self.swifter!.postStatusRetweetWithID(status.id, trimUser: false, success: {
                        json in
                        let status = Status.getStatus(json!)
                        self.alertWithTitle("Retweeted", message: "Retweeted the tweet: \(status.text) by \(status.user_screenname)")
                        }, failure: failureHandler)
                    
                    }, failure: failureHandler)
            }else{
                self.swifter!.postStatusRetweetWithID(status.id, trimUser: false, success: {
                    json in
                    let status = Status.getStatus(json!)
                    self.alertWithTitle("Retweeted", message: "Retweeted the tweet:\n\(status.text)")
                    }, failure: failureHandler)
            }
            
            
            }, failure: failureHandler)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            deleteStatus(self.statuses[indexPath.row])
            self.statuses.removeAtIndex(indexPath.row)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        } else if (editingStyle == UITableViewCellEditingStyle.Insert) {
        }
    }
    @IBAction func urlButtonClicked(sender: AnyObject, forEvent event: UIEvent) {
        fetchStatus(self.urlTextField.text)
    }
    
    func fetchStatus(url: String){
        let pattern = "http.?://twitter.com/[^/]*/status.*/(\\d{1,20})";
        let regex: NSRegularExpression = NSRegularExpression.regularExpressionWithPattern(pattern, options: nil, error: nil)!
        let resultRange = regex.firstMatchInString(url, options: nil, range: NSMakeRange(0, countElements(url)))!.rangeAtIndex(1).toRange()
        let statusId = url[resultRange!].toInt()
        let failureHandler: ((NSError) -> Void) = {
            error in

            self.alertWithTitle("Error", message: error.localizedDescription)
        }

        if(statusId != nil){
        
        swifter?.getStatusesShowWithID(statusId!, count: 1, trimUser: false, includeMyRetweet: false, includeEntities: true, success:
            {json in
                let status = Status.getStatus(json!)
                self.statuses.append(status)
                self.tableView.reloadData()
                self.saveStatus(status)
            }
            , failure: failureHandler)

      }
    }
    
    func loadStatuses () -> [Status]{
        let appDel = UIApplication.sharedApplication().delegate! as AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: "Status")
        request.returnsObjectsAsFaults = false

        let result = context.executeFetchRequest(request, error: nil)
        if(result != nil || !(result!.isEmpty)){
            return result! as [Status]
        }
        return []
    }
    
    func saveStatus(status: Status){
        let appDel = UIApplication.sharedApplication().delegate! as AppDelegate
        let context = appDel.managedObjectContext!
        context.insertObject(status)
        context.save(nil)
    }
    
    func deleteStatus(status: Status){
        let appDel = UIApplication.sharedApplication().delegate! as AppDelegate
        let context = appDel.managedObjectContext!
        context.deleteObject(status)
        context.save(nil)
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