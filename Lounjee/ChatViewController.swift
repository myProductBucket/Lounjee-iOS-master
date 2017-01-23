//
//  ConversationViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 11.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom

class ChatViewController: UIViewController {
    
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var conversationTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var conversationTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var profileImgView: ProfilePicture!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var userBanner: UIImageView!

    var commentViewHeight: NSLayoutConstraint!
    var refreshTimer: NSTimer!
    var commentView: CommentView!
    let messages = [String]()

    var requestData:RequestMatchModel?
    var conversation: ConversationModel?
    var receiver: UserModel?
    var isRequest:Bool = false
    var isAlreadyConnected:Bool = false
    var isFavorite: Bool = false
    
    var round: Bool = false
    
    var userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")

    func keybordWillShow(notification: NSNotification) {
        let infos = notification.userInfo
        let keyboardFrameBegin: NSValue = infos![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrameBeginRect = keyboardFrameBegin.CGRectValue()
        let animationDurationValue: NSNumber = infos![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationDuration = animationDurationValue.doubleValue
        let numberOfSection = self.conversationTableView.numberOfSections - 1
        let lastIndexPath = NSIndexPath(forRow: self.conversationTableView.numberOfRowsInSection(numberOfSection) - 1, inSection: numberOfSection)

        UIView.animateWithDuration(animationDuration, animations: {
            self.conversationTableViewBottom.constant = keyboardFrameBeginRect.size.height
            self.view.layoutIfNeeded()
            }) { (finished) in
                self.conversationTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func keybordWillHide(notification: NSNotification) {
        let infos = notification.userInfo
        let animationDurationValue: NSNumber = infos![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationDuration = animationDurationValue.doubleValue

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.conversationTableViewBottom.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshTimer.invalidate()
        self.refreshTimer = nil
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keybordWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keybordWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(ChatViewController.updateConversation), userInfo: nil, repeats: true)
        
        if let user = self.receiver {
            self.titleButton.setTitle(user.firstName, forState: .Normal)
            self.titleButton.titleLabel?.textAlignment = .Center
            if let lastName = user.lastName, let firstName = user.firstName {
                self.nameLabel.text = firstName + " " + lastName
            }
            self.headlineLabel.text = user.headline

            if user.pictureUrl != nil {
                self.profileImgView.sd_setImageWithURL(NSURL(string: user.pictureUrl!), placeholderImage: UIImage(named: "default-profile"))
                self.userBanner.sd_setImageWithURL(NSURL(string: user.pictureUrl!), placeholderImage: UIImage(named: "default-profile"))
            }
        }
        self.view.layoutIfNeeded()
        self.conversationTableView.reloadData()
    }
    
    @IBAction func viewProfileAction(sender: AnyObject) {
        self.performSegueWithIdentifier("viewProfile", sender: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.requestData != nil {
            UIView.animateWithDuration(0.2) {
                self.acceptBtn.alpha = 1
                self.declineBtn.alpha = 1
            }
        }
        self.scrollToBottom()
    }
    
    func scrollToBottom() {
        let indexPath = NSIndexPath(forRow: self.conversation?.messages.count ?? 0, inSection: 0)
        self.conversationTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }

    func initializeInterface() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let parameters: [String: AnyObject] = [NSFontAttributeName: UIFont.init(name: "MyriadPro-It", size: 18.0)!, NSParagraphStyleAttributeName: paragraphStyle]

        if self.conversation != nil {
            self.receiver = self.conversation?.receiver
        }

        if self.requestData != nil {
            self.receiver = self.requestData!.requestUser
            
            if self.requestData!.requestUser.id == nil{
                self.receiver!.id = self.requestData?.userId
            }
            
            self.purposeLabel.attributedText = NSAttributedString(string: self.requestData?.purpose ?? "", attributes: parameters)
            
        }
        else if let messages = self.conversation?.messages {
            let first = messages.first
            
            if first!.authorId == self.userId {
                self.purposeLabel.attributedText = NSAttributedString(string: self.receiver?.summary ?? "", attributes: parameters)
            }
            else {
                self.purposeLabel.attributedText = NSAttributedString(string: first?.content ?? "", attributes: parameters)
            }
        }
        else {
            self.purposeLabel.attributedText = NSAttributedString(string: self.receiver?.summary ?? "", attributes: parameters)
        }
        self.purposeLabel.sizeToFit()
        
        if let headerView = self.conversationTableView.tableHeaderView {
            var headerViewFrame = headerView.frame
            
            headerViewFrame.size.height = self.purposeLabel.bounds.height + 150
            headerView.frame = headerViewFrame
        }
        
        self.acceptBtn.alpha = 0
        self.declineBtn.alpha = 0
        self.profileImgView.layer.cornerRadius = CGRectGetWidth(self.profileImgView.frame) / self.profileImgView.borderRadius
        
        self.conversationTableViewBottom.constant = 0.0
        self.conversationTableView.estimatedRowHeight = 80
        self.conversationTableView.rowHeight = UITableViewAutomaticDimension
        print("RowHeight = \(self.conversationTableView.rowHeight)")
        self.conversationTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 62.0, 0.0)

        if self.isRequest == false {
            self.commentView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: self, options: nil)[0] as! CommentView
            self.commentView.frame = CGRectMake(0.0, self.view.frame.height - 52.0, self.view.frame.width, 52.0)
            self.commentView.translatesAutoresizingMaskIntoConstraints = false
            self.commentView.delegate = self
            self.view.addSubview(self.commentView)
            self.view.bringSubviewToFront(self.commentView)

            self.commentViewHeight = NSLayoutConstraint(item: self.commentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 52.0)
            var constraints = [NSLayoutConstraint(item: self.conversationTableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.commentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)]
            constraints += [NSLayoutConstraint(item: self.view, attribute: .Left, relatedBy: .Equal, toItem: self.commentView, attribute: .Left, multiplier: 1.0, constant: 0.0)]
            constraints += [NSLayoutConstraint(item: self.view, attribute: .Right, relatedBy: .Equal, toItem: self.commentView, attribute: .Right, multiplier: 1.0, constant: 0.0)]
            constraints += [self.commentViewHeight]
            self.view.addConstraints(constraints)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.initializeInterface()
    }

    func updateConversation() {
        if var conv = self.conversation {
            conv.updateMessages({ (result, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.conversationTableView.reloadData()
//                    self.scrollToBottom()
                })
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptMatch(sender: AnyObject) {
        if let request = self.requestData {
            
            // Track the event for number of the accepted request
            Intercom.logEventWithName(NumberOfAcceptedRequest)
            
            request.acceptMatch({ (result, error) in
                AnalyticsManager.track("Meeting Accepted", properties: ["Invited-UID": "\(request.userId)"])
                dispatch_async(dispatch_get_main_queue(), {
                    self.isRequest = false
                    self.initializeInterface()
                })
            })
            
        }
    }

    @IBAction func ignoreMatch(sender: AnyObject) {
        if let request = self.requestData {
            
            // Track the event for number of the rejected request
            Intercom.logEventWithName(NumberOfRejectedRequest)
            
            request.refuseMatch({ (result, error) in
                AnalyticsManager.track("Meeting Rejected", properties: ["Invited-UID": request.userId])
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewProfile" {
            // Track event to count the number of the swiped card
            Intercom.logEventWithName(NumberOfSeenFullProfile)
            
            let vc = segue.destinationViewController as! UserProfileViewController
            vc.userData = self.receiver
            vc.isRequest = self.isRequest
            vc.alreadyConnected = self.isAlreadyConnected
            vc.isFavorite = self.isFavorite
            vc.requestDelegate = nil
        }
    }
}

extension ChatViewController: TransmitterMessageCellDelegate {
    func onClickProfileImage() {
        self.performSegueWithIdentifier("viewProfile", sender: nil)
    }
}

extension ChatViewController: CommentViewDelegate {
    func commentViewDidHitSend(commentView: CommentView, message: String) {
        commentView.textView.resignFirstResponder()
        
        if var conv = self.conversation {
            conv.PostMessage(message, completion: { (result, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.conversation!.messages = result
                    self.conversationTableView.reloadData()
                    self.scrollToBottom()
                })
            })
        }
        else if let receiver = self.receiver {
            ConversationModel.getConversations({ (result, error) in
                for conv in result {
                    if conv.receiver == receiver {
                        self.conversation = conv
                        
                        self.conversation!.PostMessage(message, completion: { (result, error) in
                            dispatch_async(dispatch_get_main_queue(), {
                                self.conversation!.messages = result
                                self.conversationTableView.reloadData()
                                self.scrollToBottom()
                            })
                        })
                    }
                }
            })
        }
    }
    
    func commentViewTextDidChange(commentView: CommentView) {
        self.commentViewHeight.constant = commentView.contentSizeForTextView(commentView.textView).height + 16.0
        self.view.layoutIfNeeded()
    }

    func commentViewDidStartEditing(commentView: CommentView) {
        
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.view.endEditing(true)
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (self.conversation?.messages.count ?? 0)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let messageRadius: CGFloat = 5
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let parameters: [String: AnyObject] = [NSFontAttributeName: UIFont.init(name: "MyriadPro-Regular", size: 18.0)!, NSParagraphStyleAttributeName: paragraphStyle]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("interestCell", forIndexPath: indexPath) as! LabelTableViewCell

            if let receiver = self.receiver, let lookings = receiver.lookings {
                let labels = lookings.map({ $0["label"]! })
                
                if let currentUser = gCurrentUser, let currentUser_lookings = currentUser.lookings{
                    let currentUser_labels = currentUser_lookings.map({ $0["label"]! })
                    
                    cell.configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
            }
            
            cell.cellColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
            cell.selectionStyle = .None
            return cell
        }
        else if let message = self.conversation?.messages[indexPath.row - 1] {
            if self.userId != message.authorId {
                let cell = tableView.dequeueReusableCellWithIdentifier("transmitterCell", forIndexPath: indexPath) as! TransmitterMessageCell
                
                cell.messageView.backgroundColor = UIColor(red: 205/256, green: 205/256, blue: 205/256, alpha: 1)
                cell.messageView.layer.cornerRadius = messageRadius
                cell.delegate = self
                
                cell.profilePicture.layer.cornerRadius = CGRectGetWidth(cell.profilePicture.frame) / cell.profilePicture.borderRadius
                if let receiver = self.receiver, let pictureURL = receiver.pictureUrl {
                    cell.profilePicture.sd_setImageWithURL(NSURL(string: pictureURL), placeholderImage: UIImage(named: "default-profile"))
                }
                cell.messageLabel.attributedText = NSAttributedString(string: message.content, attributes: parameters)
                cell.selectionStyle = .None
                print("\(cell.frame.size.height)")
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("receiverCell", forIndexPath: indexPath) as! ReceiverMessageCell
                
                cell.messageView.backgroundColor = UIColor(red: 35/256, green: 145/256, blue: 175/256, alpha: 1)
                cell.messageView.layer.cornerRadius = messageRadius
                cell.messageLabel.attributedText = NSAttributedString(string: message.content, attributes: parameters)
                cell.selectionStyle = .None
                return cell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("transmitterCell", forIndexPath: indexPath)
    }
}
