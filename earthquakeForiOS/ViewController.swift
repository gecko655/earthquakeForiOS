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
    var swifter: Swifter?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
            granted, error in
            
            if granted {
                self.twitterAccounts = accountStore.accountsWithAccountType(accountType) as [ACAccount]?
                
                if self.twitterAccounts?.count == 0
                {
                    self.alertWithTitle("Error", message: "There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                }
                else {
                    self.tableView.reloadData()
                }
            }
            else {
                self.alertWithTitle("Error", message: error.localizedDescription)
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
        if(self.twitterAccounts == nil){
            return 0
        }
        return self.twitterAccounts!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
    
        
        let acAccount = self.twitterAccounts![indexPath.row] as ACAccount
        cell.textLabel!.text = acAccount.accountDescription
        
        return cell
        
    }
    
    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let indexPath = self.tableView.indexPathForSelectedRow()
        let twitterAccount = self.twitterAccounts![indexPath!.row]
        self.swifter = Swifter(account: twitterAccount)
        let mainViewController :MainViewController = segue.destinationViewController as MainViewController
        mainViewController.swifter = self.swifter
        
    }

}

