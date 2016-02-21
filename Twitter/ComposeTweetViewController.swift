//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Marcel Weekes on 2/21/16.
//  Copyright © 2016 Marcel Weekes. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {

    // set by the presenting controller
    var user: User!
    var originalTweet: Tweet?
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var screennameLabel: UILabel!
    @IBOutlet private weak var tweetTextView: UITextView!
    

    var tweetContents: String {
        return tweetTextView.text
    }
    
    var replyToStatusId: NSNumber? {
        return originalTweet?.id
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = user.profileImageUrlString {
            if let imageURL = NSURL(string: urlString) {
                profileImageView.setImageWithURL(imageURL)
                profileImageView.layer.cornerRadius = 4
                profileImageView.clipsToBounds = true
            }
        }
        usernameLabel.text = user?.name
        screennameLabel.text = "@\(user!.screenname!)"
        
        // reply state
        configureForReply()
        
        tweetTextView.becomeFirstResponder()
    }
    
    func configureForReply() {
        if let orig = originalTweet {
            tweetTextView.text = "@\(orig.user!.screenname!) "
        }
    }
    
    
    // MARK: - Actions

    @IBAction func cancelCompose(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
