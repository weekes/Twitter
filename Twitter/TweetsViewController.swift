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
    private var refreshControl: UIRefreshControl!
    private var loadingAdditionalTweets = false
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshTweets", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        refreshTweets()
    }
    
    // MARK: - API Access

    func refreshTweets() {
        fetchTweets(nil)
    }
    
    private func loadAdditionalTweets() {
        if let max_id = tweets?.last?.id {
            let max_id_string = String(max_id)
            let params = ["max_id": max_id_string]
            fetchTweets(params)
        }
    }
    
    private func fetchTweets(params: NSDictionary?) {
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (tweets, error) -> () in
            self.loadingAdditionalTweets = false
            self.tweets = tweets
            self.tableView.reloadData()
            if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "tweetDetailsSegue" {
            let cell = sender as! TweetCell
            let detailsVC = segue.destinationViewController as! TweetDetailViewController
            detailsVC.tweet = cell.tweet
        }
        
        if segue.identifier == "composeSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let composeVC = navController.topViewController as! ComposeTweetViewController
            composeVC.user = User.currentUser
        }
    }

    
    // MARK: - Actions
    
    @IBAction func postTweet(sender: UIStoryboardSegue) {
        let composeTweetVC = sender.sourceViewController as! ComposeTweetViewController
        let tweetText = composeTweetVC.tweetContents
        var params = ["status": tweetText]
        
        if let replyToStatusId = composeTweetVC.replyToStatusId {
            let replyId = String(replyToStatusId)
            print("this is a reply to \(replyId)")
            
            params["in_reply_to_status_id"] = String(replyToStatusId)
        }
        
        TwitterClient.sharedInstance.composeTweetWithCompletion(params) { (success, error) -> () in
            // insert at front of tweets array
            let freshTweet = Tweet(user: User.currentUser!, text: tweetText)
            self.tweets?.insert(freshTweet, atIndex: 0)
            
            // reload
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

// MARK: - UITableViewDelegate
extension TweetsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !loadingAdditionalTweets {
            // determine height of tableView and threshold for requesting more tweets
            let scrollViewContentHeight = tableView.contentSize.height
            let additionalDataThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if scrollView.contentOffset.y > additionalDataThreshold && (tableView.dragging) {
                loadingAdditionalTweets = true
                loadAdditionalTweets()
            }
        }
    }
}