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

class MainViewController: UITableViewController, UITextFieldDelegate{
    
    var swifter: Swifter!
    var statuses: [Status] = []
    
    func failureHandler(error: NSError) -> Void {
        alertWithTitle("Error", message: error.localizedDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let load = loadStatuses() {
            statuses += load
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.reloadData()
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "statusCell"
        let cell: StatusCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StatusCell
        cell.reflect(statuses[indexPath.row])
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let status = statuses[indexPath.row]
        swifter.getStatusesShowWithID(status.id_str, count: 1, trimUser: false, includeMyRetweet: true, includeEntities: false, success: {
            jsonFetched in
            if(jsonFetched?["retweeted"]?.bool == true){
                if let id_str = jsonFetched?["current_user_retweet"]?["id_str"].string {
                    self.swifter.postStatusesDestroyWithID(id_str, trimUser: false, success:{
                        json in
                        self.doRT(status)
                        }, failure: self.failureHandler)
                }
            }else{
                self.doRT(status)
            }
            
            
            }, failure: failureHandler)
    }
    func doRT(status: Status){
        swifter.postStatusRetweetWithID(status.id_str, trimUser: false, success: {
            json in
            let status = Status.getStatus(json!)
            self.alertWithTitle("Retweeted", message: "Retweeted the tweet: \(status.text) by \(status.user_screenname)")
            }, failure: failureHandler)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            deleteStatus(statuses[indexPath.row])
            statuses.removeAtIndex(indexPath.row)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        } else if (editingStyle == UITableViewCellEditingStyle.Insert) {
        }
    }
    @IBAction func urlButtonClicked(sender: AnyObject, forEvent event: UIEvent) {
        if let clipboard = UIPasteboard.generalPasteboard().string{
            fetchStatus(clipboard)
        }else{
            self.alertWithTitle("Error", message: "No content in clipboard")
        }
        
    }
    
    func fetchStatus(url: String){
        let pattern = "http.?://[^/]*twitter.com/.*/status[^/]*/(\\d{1,20})";
        let regex = NSRegularExpression(pattern: pattern, options: nil, error: nil)!
        if let resultRange = regex.firstMatchInString(url, options: nil, range: NSMakeRange(0, count(url)))?.rangeAtIndex(1).toRange(){
            let statusId = url[resultRange]
            swifter.getStatusesShowWithID(statusId, count: 1, trimUser: false, includeMyRetweet: false, includeEntities: true, success:
                {json in
                    let status = Status.getStatus(json!)
                    self.saveStatus(status)
                }
                , failure: failureHandler)
        }else{
            self.alertWithTitle("Invalid tweet URL", message: "Clip board should be like \n\"https://twitter.com/gecko655/status/604609734788800513\"\n Your input was \n\"\(url)\"")
        }
    }
    
    func loadStatuses () -> [Status]?{
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: "Status")
        request.returnsObjectsAsFaults = false

        let result = context.executeFetchRequest(request, error: nil)
        return result as? [Status]
        
    }
    
    func saveStatus(status: Status){
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: "Status")
        request.predicate = NSPredicate(format: "id_str=%@", status.id_str)
        let result = context.executeFetchRequest(request, error: nil)
        if (result != nil && result!.isEmpty){
            context.insertObject(status)
            statuses.append(status)
            self.tableView.reloadData()
            self.alertWithTitle("Success", message: "Successfully saved This tweet:\n@\(status.user_screenname) \(status.text)")
        }else{
            context.rollback()
            self.alertWithTitle("Error", message: "Tweet already exists in this app:\n@\(status.user_screenname) \(status.text)")
        }
        context.save(nil)
    }
    
    func deleteStatus(status: Status){
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
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