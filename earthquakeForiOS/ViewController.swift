//
//  ViewController.swift
//  earthquakeForiOS
//
//  Created by akihiro on 2014/09/06.
//  Copyright (c) 2014年 gecko655. All rights reserved.
//

import UIKit
import Accounts
import SwifteriOS

class ViewController: UITableViewController {

    var twitterAccounts: [ACAccount]?
    
    func openPrivacySettings(action: UIAlertAction!){
        let url = NSURL(string:UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
            granted, error in
            
            if granted {
                self.twitterAccounts = accountStore.accountsWithAccountType(accountType) as! [ACAccount]?
                
                if self.twitterAccounts?.count > 0 {
                    dispatch_async(dispatch_get_main_queue()){
                            self.tableView.reloadData()
                        }
                } else {
                    self.alertWithTitle("Error", message: "There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                }
            }
            else {
                self.alertWithTitle("Error", message: "Access to Twitter accounts was denied\n Please configure privacy settings.",
                    handler: self.openPrivacySettings)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitterAccounts?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 
    
        
        let acAccount = self.twitterAccounts![indexPath.row] as ACAccount
        cell.textLabel?.text = acAccount.accountDescription
        
        return cell
        
    }
    
    func alertWithTitle(title: String, message: String, handler: ((UIAlertAction!) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let indexPath = self.tableView.indexPathForSelectedRow
        let twitterAccount = self.twitterAccounts![indexPath!.row]
        let swifter = Swifter(account: twitterAccount)
        let mainViewController :MainViewController = segue.destinationViewController as! MainViewController
        mainViewController.swifter = swifter
        
    }

}

