//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Marcel Weekes on 2/18/16.
//  Copyright © 2016 Marcel Weekes. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    var tweets: [Tweet]?
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        }
    }

    @IBAction func onLogout(sender: UIButton) {
        if let user = User.currentUser {
            let alertVC = UIAlertController(title: user.screenname, message: "Are you sure you want to sign out of Twitter?", preferredStyle: .Alert)
            let logoutAction = UIAlertAction(title: "Sign out", style: .Default) { (action) in
                user.logout()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // dismiss
            }
            alertVC.addAction(logoutAction)
            alertVC.addAction(cancelAction)
            
            presentViewController(alertVC, animated: true, completion: nil)
        }
        
    }
}


// MARK: - UITableViewDataSource
extension TweetsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        
        if let tweets = tweets {
            let tweet = tweets[indexPath.row]
            cell.tweet = tweet
        }
        
        return cell
    }
    
}
