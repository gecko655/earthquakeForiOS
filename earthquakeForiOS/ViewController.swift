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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UITableViewController {

    var twitterAccounts: [ACAccount]?
    
    func openPrivacySettings(_ action: UIAlertAction?){
        let url = URL(string:UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccounts(with: accountType, options: nil) {
            granted, error in
            
            if granted {
                self.twitterAccounts = accountStore.accounts(with: accountType) as! [ACAccount]?
                
                if self.twitterAccounts?.count > 0 {
                    DispatchQueue.main.async{
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitterAccounts?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell :UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) 
    
        
        let acAccount = self.twitterAccounts![indexPath.row] as ACAccount
        cell.textLabel?.text = acAccount.accountDescription
        
        return cell
        
    }
    
    func alertWithTitle(_ title: String, message: String, handler: ((UIAlertAction?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let indexPath = self.tableView.indexPathForSelectedRow
        let twitterAccount = self.twitterAccounts![indexPath!.row]
        let swifter = Swifter(account: twitterAccount)
        let mainViewController :MainViewController = segue.destination as! MainViewController
        mainViewController.swifter = swifter
        
    }

}

