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
    var statuses: [(id: Int, text: String)] = []
    
    
    @IBOutlet var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statusesLoad = loadStatuses()
        for status in statusesLoad{
            statuses.append(status)
        }
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "mainCell"
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = statuses[indexPath.row].text
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let status = statuses[indexPath.row]
        let failureHandler: ((NSError) -> Void) = {
            error in

            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        swifter?.postStatusRetweetWithID(status.id, trimUser: false, success: {
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
                let s = (id: status!["id"]!.integer!, text: status!["text"]!.string!)
                self.statuses.append(s)
                self.tableView.reloadData()
                self.saveStatus(status!)
            }
            , failure: failureHandler)

      }
    }
    
    func loadStatuses () -> [(id: Int,text: String)]{
        var ret:[(id: Int,text: String)] = []
        let appDel = UIApplication.sharedApplication().delegate! as AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: "Statuses")
        request.returnsObjectsAsFaults = false

        let result = context.executeFetchRequest(request, error: nil)
        if(result != nil || !(result!.isEmpty)){
            for res in result! as [NSManagedObject]{
                let id = res.valueForKey("id") as Int
                let text = res.valueForKey("text") as String
                let status = (id: id,text: text)
                ret.append(status)
            }
        }
        return ret
    }
    
    func saveStatus(status: Dictionary<String,JSONValue>){
        let appDel = UIApplication.sharedApplication().delegate! as AppDelegate
        let context = appDel.managedObjectContext!
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Statuses", inManagedObjectContext: context) as NSManagedObject
        entity.setValue(status["id"]!.integer!, forKey: "id")
        entity.setValue(status["text"]!.string!, forKey: "text")
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