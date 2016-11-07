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
    
    func failureHandler(_ error: Error) -> Void {
        alertWithTitle("Error", message: error.localizedDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let load = loadStatuses() {
            statuses += load
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.reloadData()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "statusCell"
        let cell: StatusCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! StatusCell
        cell.reflect(statuses[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let status = statuses[indexPath.row]
        swifter.getTweet(forID: status.id_str, count: 1, trimUser: false, includeMyRetweet: true, includeEntities: false,  success: {
            jsonFetched in
            if(jsonFetched["retweeted"].bool == true){
                if let id_str = jsonFetched["current_user_retweet"]["id_str"].string {
                    self.swifter.destroyTweet(forID: id_str, trimUser: false, success:{
                        json in
                        self.doRT(status)
                        }, failure: self.failureHandler)
                }
            }else{
                self.doRT(status)
            }
            
            
            }, failure: self.failureHandler)
    }
    func doRT(_ status: Status){
        swifter.retweetTweet(forID: status.id_str, trimUser: false, success: {
            json in
            let status = Status.getStatus(json)
            self.alertWithTitle("Retweeted", message: "Retweeted the tweet: \(status.text) by \(status.user_screenname)")
            }, failure: failureHandler)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            deleteStatus(statuses[indexPath.row])
            statuses.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        } else if (editingStyle == UITableViewCellEditingStyle.insert) {
        }
    }
    @IBAction func urlButtonClicked(_ sender: AnyObject, forEvent event: UIEvent) {
        if let clipboard = UIPasteboard.general.string{
            fetchStatus(clipboard)
        }else{
            self.alertWithTitle("Error", message: "No content in clipboard")
        }
        
    }
    
    func fetchStatus(_ url: String){
        let pattern = "http.?://[^/]*twitter.com/.*/status[^/]*/(\\d{1,20})";
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        if let resultRange = regex.firstMatch(in: url, options: [], range: NSMakeRange(0, url.characters.count))?.rangeAt(1).toRange(){
            let statusId = url[resultRange]
            swifter.getTweet(forID: statusId, count: 1, trimUser: false, includeMyRetweet: false, includeEntities: true, success:
                {json in
                    let status = Status.getStatus(json)
                    self.saveStatus(status)
                }
                , failure: failureHandler)
        }else{
            self.alertWithTitle("Invalid tweet URL", message: "Clip board should be like \n\"https://twitter.com/gecko655/status/604609734788800513\"\n Your input was \n\"\(url)\"")
        }
    }
    
    func loadStatuses () -> [Status]?{
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Status")
        request.returnsObjectsAsFaults = false

        let result = try? context.fetch(request)
        return result as? [Status]
        
    }
    
    func saveStatus(_ status: Status){
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Status")
        request.predicate = NSPredicate(format: "id_str=%@", status.id_str)
        let result = try? context.fetch(request)
        if (result != nil && result!.isEmpty){
            context.insert(status)
            statuses.append(status)
            self.tableView.reloadData()
            self.alertWithTitle("Success", message: "Successfully saved This tweet:\n@\(status.user_screenname) \(status.text)")
        }else{
            context.rollback()
            self.alertWithTitle("Error", message: "Tweet already exists in this app:\n@\(status.user_screenname) \(status.text)")
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func deleteStatus(_ status: Status){
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        let context = appDel.managedObjectContext!
        context.delete(status)
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func alertWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
extension String
{
    subscript(integerIndex: Int) -> Character
    {
        let index = characters.index(startIndex, offsetBy: integerIndex)
            return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String
    {
        let start = characters.index(startIndex, offsetBy: integerRange.lowerBound)
        let end = characters.index(startIndex, offsetBy: integerRange.upperBound)
        let range = start..<end
        return self[range]
    }
}
