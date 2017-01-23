//
//  MessagesViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 10.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom

//protocol DiscoveryRequestDelegateForFavorite {
//    func meetActionDelegateForfavorite()
//}

class MessagesViewController: UIViewController, DiscoveryRequestDelegate {//DiscoveryRequestDelegate
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: <Give a reason to meet ...>
    @IBOutlet weak var requestViewEffect: UIVisualEffectView!
    @IBOutlet weak var keyboardAvoidingScrollView: UIScrollView!
    
    @IBOutlet weak var requestMatchView: UIView!
    
    @IBOutlet weak var requestCollectionView: UICollectionView!
    
    @IBOutlet weak var requestName: UILabel!
    @IBOutlet weak var requestProfilePicture: ProfilePicture!
    @IBOutlet weak var requestHeadline: UILabel!
    
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestTextView: UITextView!
    
    // MARK: -
    var requestMatches = [RequestMatchModel]()
    var conversations = [ConversationModel]()
    var conversations_duplicated = [ConversationModel]()
    
    var currentMatchLookingFor = [String]()
    
    var favorites = [UserModel]()
    var favoriteIndex: Int = 0 // Selected favorite index
    
    private var matchedArray = [Int]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestViewEffect.alpha = 0
        self.keyboardAvoidingScrollView.hidden = true
        
      self.fetchDataForMatchesAndFavorites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Add done button in TextView
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items = [
            //            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelNumberPad")),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.doneWithKeyboard))]
        numberToolbar.sizeToFit()
        self.requestTextView.inputAccessoryView = numberToolbar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = sender as? NSIndexPath {
            if indexPath.section == 0 {// Conversation
                if let viewController = segue.destinationViewController as? ChatViewController {
                    let row = indexPath.row
                    viewController.hidesBottomBarWhenPushed = true
                    
                    if indexPath.row < self.requestMatches.count {
                        viewController.requestData = requestMatches[row]
                        viewController.isRequest = true
                    }
                    else if indexPath.row - self.requestMatches.count < self.conversations.count {
                        viewController.conversation = conversations[indexPath.row - self.requestMatches.count]
                        if self.isFavoriteUser(viewController.conversation!) {
                            viewController.isFavorite = true
                        }
                        viewController.isAlreadyConnected = true
                    }
                }
            }
        }
    }
    
    func fetchDataForMatchesAndFavorites() {
        self.activityIndicator.startAnimating()
        self.matchesTableView.hidden = true
        self.noResultLabel.hidden = true
        
        self.requestMatches = []
        self.conversations = []
        
        self.matchesTableView.reloadData()
        
        DiscoveryModel.GetRequestedMatches { (result, error) in
            self.requestMatches = result // Received the request from other users
            
            // Add the custom attribute for number of the received request
            Intercom.updateUserWithAttributes([NumberOfReceivedRequest: self.requestMatches.count])
            
            ConversationModel.getConversations { (result, error) in
                
                self.conversations = result
                
                // Add the custom attribute for number of the received request
//                Intercom.updateUserWithAttributes([NumberOfChats: self.conversations.count])
                
                self.conversations_duplicated = result
                
                var conversationID = self.conversations.count - 1
                for conversation in self.conversations.reverse(){
                    
                    var dupNum = 1
                    
                    for conversation_for_search in self.conversations.reverse(){
                        
                        if (conversation.id == conversation_for_search.id) ||
                            (conversation.receiver.firstName?.compare(conversation_for_search.receiver.firstName!) == NSComparisonResult.OrderedSame &&
                                conversation.receiver.lastName?.compare(conversation_for_search.receiver.lastName!) == NSComparisonResult.OrderedSame){
                            
                            if dupNum >= 2{
                                self.conversations.removeAtIndex(conversationID)
                            }
                            
                            dupNum += 1
                        }
                    }
                    
                    conversationID -= 1
                }
                
                var emptyChatCount: Int = 0
                for conversation in self.conversations {
                    if let messages = conversation.messages as [MessageModel]?{
                        if messages.count <= 1 {
                            emptyChatCount += 1
                        }
                    }
                }
                Intercom.updateUserWithAttributes([NumberOfEmptyChats : emptyChatCount])
                
                dispatch_async(dispatch_get_main_queue(), {
//                    self.matchesTableView.hidden = (self.conversations.count + self.requestMatches.count == 0 && self.favorites.count == 0)
//                    self.noResultLabel.hidden = !self.matchesTableView.hidden
                    self.activityIndicator.stopAnimating()
                    self.matchesTableView.reloadData()
                    self.matchesTableView.hidden = false
                })
            }
        }
        
        /*
         DiscoveryModel.GetRequestedMatches { (result, error) in
         self.requestMatches = result
         
         ConversationModel.getConversations { (result, error) in
         
         self.conversations = result
         self.conversations_duplicated = result
         
         var conversationID = self.conversations.count - 1
         for conversation in self.conversations.reverse(){
         
         var dupNum = 1
         
         for conversation_for_search in self.conversations.reverse(){
         
         if (conversation.id == conversation_for_search.id) ||
         (conversation.receiver.firstName?.compare(conversation_for_search.receiver.firstName!) == NSComparisonResult.OrderedSame &&
         conversation.receiver.lastName?.compare(conversation_for_search.receiver.lastName!) == NSComparisonResult.OrderedSame){
         
         if dupNum >= 2{
         self.conversations.removeAtIndex(conversationID)
         }
         
         dupNum += 1
         }
         }
         
         conversationID -= 1
         }
         
         dispatch_async(dispatch_get_main_queue(), {
         self.matchesTableView.hidden = (self.conversations.count + self.requestMatches.count == 0)
         self.noResultLabel.hidden = !self.matchesTableView.hidden
         self.activityIndicator.stopAnimating()
         self.matchesTableView.reloadData()
         })
         }
         }
         
         */
        
        FavoriteModel.GetFavorites { (result, error) in
            self.favorites = result
            dispatch_async(dispatch_get_main_queue(), {
//                self.matchesTableView.hidden = (self.conversations.count + self.requestMatches.count == 0 && self.favorites.count == 0)
//                self.noResultLabel.hidden = !self.matchesTableView.hidden
                self.matchesTableView.hidden = false
                self.activityIndicator.stopAnimating()
                self.matchesTableView.reloadData()
            })
        }
    }
    
    func isConnectedUser(favorite: UserModel) -> Bool {
        for conversation in self.conversations {
            if favorite.id == conversation.id {
                return true
            }
        }
        return false
    }
    
    func isFavoriteUser(conversation: ConversationModel) -> Bool {
        let receiver = conversation.receiver
        for favorite in self.favorites {
            if favorite.id == receiver.id {
                return true
            }
        }
        return false
    }
    
    // MARK: 
    @IBAction func closeRequestMatchView(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            
            self.navigationController?.navigationBarHidden = false
            self.tabBarController?.tabBar.hidden = false
            self.extendedLayoutIncludesOpaqueBars = false
            self.edgesForExtendedLayout = UIRectEdge.None
            
            self.requestViewEffect.alpha = 0
            self.keyboardAvoidingScrollView.hidden = true
            
            self.requestTextView.resignFirstResponder()
            self.matchesTableView.reloadData()
        })
    }
    
    @IBAction func requestMatchBtn(sender: AnyObject) {
        let meetingPurpose = self.requestTextView.text
        
        if self.requestTextView.text.compare("") == NSComparisonResult.OrderedSame{
            let alertView = UIAlertView(title: "Warning", message: "Please write a message to send the request.", delegate: nil, cancelButtonTitle: "OK" )
            alertView.show()
            
            return
        }
        
        if self.requestTextView.text.compare("Type a message...") == NSComparisonResult.OrderedSame{
            let alertView = UIAlertView(title: "Warning", message: "Please write a message to send the request.", delegate: nil, cancelButtonTitle: "OK" )
            alertView.show()
            
            return
        }
        
        self.requestMatch(meetingPurpose)
    }
    
    func requestMatch(reason: String) {
        
        if let user = self.favorites[favoriteIndex] as UserModel? {
            
            // Track the events for number of the sent request
            Intercom.logEventWithName(NumberOfSentRequest)
            
            AnalyticsManager.track("Meeting Invite Sent", properties: ["Invited-UID": "\(user.id!)", "InviteTextEmpty": (reason.characters.count == 0)])
            
            DiscoveryModel.PostRequestMatch(user, reason: reason)
            view.endEditing(true)
            UIView.animateWithDuration(0.20, animations: {
                self.requestViewEffect.alpha = 0
                self.keyboardAvoidingScrollView.hidden = true
                
                }, completion: { (finished) in

//                    self.matchesTableView.hidden = (self.conversations.count + self.requestMatches.count == 0 && self.favorites.count == 0)
//                    self.noResultLabel.hidden = !self.matchesTableView.hidden
                    
                    self.navigationController?.navigationBarHidden = false
                    self.tabBarController?.tabBar.hidden = false
                    self.extendedLayoutIncludesOpaqueBars = false
                    self.edgesForExtendedLayout = UIRectEdge.None
                    
                    self.requestViewEffect.alpha = 0
                    self.keyboardAvoidingScrollView.hidden = true
                    
                    self.requestTextView.resignFirstResponder()
            })
        }
    }
    
    func doneWithKeyboard() {
        self.view.endEditing(true)
    }
    
    func enableRequestView(){
        
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.Bottom
        
        if let user = self.favorites[favoriteIndex] as UserModel? {
            
            if let offers = user.lookings {
                let labels = offers.map({ $0["label"]! })
                self.currentMatchLookingFor = labels as! [String]
                
                if let currentUser = gCurrentUser, let currentUser_LookingFor = currentUser.lookings {
                    let currentUser_labels = currentUser_LookingFor.map({ $0["label"]! })
                    self.configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
                
                self.requestCollectionView.reloadData()
            }
            
            self.requestProfilePicture.layer.cornerRadius = CGRectGetWidth(self.requestProfilePicture.frame)/self.requestProfilePicture.borderRadius
            
            if let firstname = user.firstName {
                self.requestName.text = firstname
                self.requestTitle.text = "Give a reason to meet " + firstname
                
                self.requestTextView.text = "Type a message..."
                self.requestTextView.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 142/255.0, alpha: 1.0)
            }
            
            if let pictureUrl = user.pictureUrl {
                self.requestProfilePicture.sd_setImageWithURL(NSURL(string: pictureUrl), placeholderImage: UIImage(named: "default-profile"))
            }
            else {
                self.requestProfilePicture.image = UIImage(named: "default-profile")
            }
            
            if let headline = user.headline {
                self.requestHeadline.text = headline
            }
            
            UIView.animateWithDuration(0.3, animations: {
                self.requestViewEffect.alpha = 1
                self.keyboardAvoidingScrollView.hidden = false
            })
        }
    }
    
    func configureWithData(data: [String], currentUser_data: [String]) {
        
        matchedArray.removeAll()
//        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumLineSpacing = 10.0
//            layout.minimumInteritemSpacing = 10.0
//            layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
//        }
        
        //        self.data = data
        //        self.currentUser_data = currentUser_data
        
        var matched_flag = false
        
        for data_element in data{
            
            matched_flag = false
            for userdata_element in currentUser_data{
                if data_element.compare(userdata_element) == NSComparisonResult.OrderedSame{
                    matched_flag = true
                    matchedArray.append(1)
                }
            }
            
            if matched_flag == false{
                matchedArray.append(0)
            }
        }
        
        // Resort to display the matched item first
        
        var index: Int = 0
        for statusItem in matchedArray {
            if statusItem == 1 {
                matchedArray.removeAtIndex(index)
                matchedArray.insert(1, atIndex: 0)
                let datum = self.currentMatchLookingFor[index]
                self.currentMatchLookingFor.removeAtIndex(index)
                self.currentMatchLookingFor.insert(datum, atIndex: 0)
            }
            
            index += 1
        }
    }
    
    // MARK: DiscoveryRequestDelegate
    func meetActionDelegate() {
        self.dismissViewControllerAnimated(true, completion: {
            self.enableRequestView()
        })
    }
    
    // MARK: Favorite Item Touch Up
    func favoriteItemTouchUp(sender: UIButton) {
//        print("Selected Index: \(sender.tag)")
        favoriteIndex = sender.tag
        if let selectedUser = self.favorites[sender.tag] as UserModel? {
            
            let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            
            var isConnected: Bool = false
            for conversation in self.conversations {
                if selectedUser.id == conversation.receiver.id {
                    chatVC.conversation = conversation
                    isConnected = true
                }
            }
            
            if isConnected {
                chatVC.isFavorite = true
                chatVC.isAlreadyConnected = true
                
                self.navigationController?.pushViewController(chatVC, animated: true)
            }else{
            
                let profileVC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController
                profileVC?.userData = selectedUser
                profileVC?.isRequest = true
                profileVC?.requestDelegate = self
                profileVC?.isFavorite = true
                
                self.presentViewController(profileVC!, animated: true, completion: {
                    
                })
                
                // Track event to count the number of the swiped card
                Intercom.logEventWithName(NumberOfSeenFullProfile)
            }
        }
    }
}

extension MessagesViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.requestCollectionView {
            let label = UILabel()
            
            label.font = UIFont.init(name: "MyriadPro-Bold", size: 12)!
            label.text = self.currentMatchLookingFor[indexPath.row].uppercaseString
            label.sizeToFit()
            return CGSizeMake(label.bounds.width + 10.0, 23.0)
        }
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height)
    }
}

extension MessagesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == self.requestCollectionView {
            return self.currentMatchLookingFor.count
//        }
//        return self.potentialMatches.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
//        if collectionView == self.requestCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! InterestCollectionViewCell
        
            if matchedArray[indexPath.row] == 1{
                cell.backgroundColor = UIColor.init(red: 35.0/255.0, green: 149.0/255.0, blue: 175.0/255.0, alpha: 1.0)
                cell.interestLabel.textColor = UIColor.whiteColor()
                cell.layer.borderColor = UIColor.init(red: 35.0/255.0, green: 149.0/255.0, blue: 175.0/255.0, alpha: 1.0).CGColor
            }
            else{
                cell.backgroundColor = UIColor.clearColor()
                cell.interestLabel.textColor = UIColor.init(red: 35.0/255.0, green: 149.0/255.0, blue: 175.0/255.0, alpha: 1.0)
                
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = UIColor.init(red: 35.0/255.0, green: 149.0/255.0, blue: 175.0/255.0, alpha: 1.0).CGColor
            }
            
            //cell.backgroundColor = self.cellColor
            cell.interestLabel.textAlignment = .Center
        
            cell.interestLabel.text = self.currentMatchLookingFor[indexPath.row].uppercaseString
            return cell
//        }
    }
}

extension MessagesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && self.requestMatches.count + self.conversations.count > 0{
            self.performSegueWithIdentifier("conversationSegue", sender: indexPath)
        }else{// Favorite Profile
            
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.requestMatches.count + self.conversations.count == 0 {
                return 240
            }else{
                return 80
            }
        }else{
            return 110
        }
    }
}

extension MessagesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView

        header.textLabel!.font = UIFont.init(name: "MyriadPro-Cond", size: 18)
        header.textLabel!.textColor = UIColor.lightGrayColor()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil//"DISCUSSIONS"
        }else{
            return "FAVORITES"
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }else{
            return 32.0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.requestMatches.count + self.conversations.count == 0 {
                return 1
            }else{
                return self.requestMatches.count + self.conversations.count
            }
        }else{
            return 1//self.favorites.count
        }
    }
    
    func stringFromTimeInterval(fromDate : NSDate, toDate: NSDate) -> String{
        let sysCalendar = NSCalendar.currentCalendar()
        
        let unitFlags: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
        let components = sysCalendar.components(unitFlags, fromDate: fromDate, toDate: toDate, options: [])
        
        let comp = sysCalendar.components([.Hour, .Minute], fromDate: fromDate)
        let hour = comp.hour
        let minute = comp.minute
        
        var returnStr: String
        if components.month > 0{
            if components.month == 1{
                
                returnStr = String(format: "a month ago")
                //if hour > 12{
                //    returnStr = String(format: "a month ago at %d:%d PM", components.month, hour - 12, minute)
                //}else{
                //    returnStr = String(format: "a months ago at %d:%d AM", components.month, hour, minute)
                //}
                
                return returnStr
            }
            else{
                
                returnStr = String(format: "%d months ago", components.month)
                //if hour > 12{
                //    returnStr = String(format: "%d months ago at %d:%d PM", components.month, hour - 12, minute)
                //}else{
                //    returnStr = String(format: "%d months ago at %d:%d AM", components.month, hour, minute)
                //}
                
                return returnStr
            }
        }
        
        if components.day > 0{
            if components.day == 1{
                
                returnStr = String(format: "Yesterday")
                //if hour > 12{
                //    returnStr = String(format: "Yesterday at %d:%d PM", hour - 12, minute)
                //}else{
                //    returnStr = String(format: "Yesterday at %d:%d AM", hour, minute)
                //}
                
                return returnStr
            }
            else{
                
                returnStr = String(format: "%d days ago", components.day)
                //if hour > 12{
                //    returnStr = String(format: "%d days ago at %d:%d PM", components.day, hour - 12, minute)
                //}else{
                //    returnStr = String(format: "%d days ago at %d:%d AM", components.day, hour, minute)
                //}
                
                return returnStr
            }
        }
        
        returnStr = String(format: "%d:%d", hour, minute)
        return returnStr
        
        /*if components.hour > 0{
            if components.hour == 1{
                return "an hour ago"
            }
            else{
                returnStr = String(format: "%d:%d", hour, minute)
                return returnStr
            }
        }
        
        if components.minute > 0{
            if components.minute == 1{
                return "a min ago"
            }
            else{
                returnStr = String(format: "%d mins ago", components.minute)
                return returnStr
            }
        }
        
        return "a min ago"*/
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if self.requestMatches.count + self.conversations.count == 0 {
                let cell = UITableViewCell()
                let w = UIScreen.mainScreen().bounds.size.width
                var nw: CGFloat = 0
                var nh: CGFloat = 0
                var nx: CGFloat = 0
                var ny: CGFloat = 0
                if (w * 93.0 / 432.0) < 240.0 {
                    nw = w
                    nh = w * 93.0 / 432.0
                    nx = 0
                    ny = (240.0 - nh) / 2.0
                }else{
                    nw = 240.0 * 432.0 / 93.0
                    nh = 240.0
                    nx = (w - nw) / 2.0
                    ny = 0
                }
                let noMatchesView = UIView(frame: CGRect(x: 0, y: 0, width: w, height: 240))
                noMatchesView.backgroundColor = UIColor.whiteColor()
                let noMatchesImageV = UIImageView(frame: CGRect(x: nx, y: ny, width: nw, height: nh))
                noMatchesImageV.image = UIImage(named: "NoMatchesYet")
                noMatchesView.addSubview(noMatchesImageV)
                
                cell.contentView .addSubview(noMatchesView)
                
                return cell
            }else{
                if indexPath.row < self.requestMatches.count {
                    let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as! ListRequestTableViewCell
                    let request = self.requestMatches[indexPath.row]
                    
                    cell.messageLabel.text = request.purpose
                    
                    if let firstName = request.requestUser.firstName {
                        //cell.nameLabel.text = firstName
                        cell.nameLabel.text = firstName + " " + request.requestUser.lastName!
                    }
                    
                    let currentDate = NSDate()
                    let messageUpdatedDate = request.updatedAt
                    
                    cell.timeLabel.text = self.stringFromTimeInterval(messageUpdatedDate, toDate: currentDate)
                    
                    cell.profileImageView.layer.cornerRadius = CGRectGetWidth(cell.profileImageView.frame) / cell.profileImageView.borderRadius
                    cell.profileImageView.image = nil
                    if let pictureUrl = request.requestUser.pictureUrl {
                        cell.profileImageView.sd_setImageWithURL(NSURL(string: pictureUrl), placeholderImage: UIImage(named: "default-profile"))
                    }
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as! ListMessageTableViewCell
                    cell.profileImgView.layer.cornerRadius = CGRectGetWidth(cell.profileImgView.frame) / cell.profileImgView.borderRadius
                    
                    cell.profileImgView.image = nil
                    cell.nameLabel.text = nil
                    cell.messageLabel.text = nil
                    
                    let conversation = self.conversations[indexPath.row - self.requestMatches.count]
                    let user = conversation.receiver
                    
                    if let pictureUrl = user.pictureUrl {
                        cell.profileImgView.sd_setImageWithURL(NSURL(string: pictureUrl), placeholderImage: UIImage(named: "default-profile"))
                    }
                    
                    if let firstName = user.firstName {
                        cell.nameLabel.text = firstName + " " + user.lastName!
                    }
                    cell.messageLabel.text = conversation.getLastMessage()
                    
                    let userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
                    let conversationAuthorId = conversation.getLastMessageAuthor()
                    
                    let currentDate = NSDate()
                    let messageUpdatedDate = conversation.getLastMessageUpdatedDate()
                    
                    cell.timeLabel.text = self.stringFromTimeInterval(messageUpdatedDate, toDate: currentDate)
                    
                    if userId != conversationAuthorId{
                        cell.meTextWidth.constant = 0
                    }
                    
                    return cell
                }
            }
        }else{
//            let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! ListFavoriteTableViewCell
//            cell.profileImgView.layer.cornerRadius = CGRectGetWidth(cell.profileImgView.frame) / cell.profileImgView.borderRadius
//            
//            cell.profileImgView.image = nil
//            cell.nameLabel.text = nil
//            cell.cityLabel.text = nil
//            cell.countryLabel.text = nil
//            
//            let favorite = self.favorites[indexPath.row - self.requestMatches.count]
//            
//            if let pictureUrl = favorite.pictureUrl {
//                cell.profileImgView.sd_setImageWithURL(NSURL(string: pictureUrl), placeholderImage: UIImage(named: "default-profile"))
//            }else{
//                cell.profileImgView.image = UIImage(named: "default-profile")
//            }
//            
//            if let firstName = favorite.firstName {
//                cell.nameLabel.text = firstName + " " + favorite.lastName!
//            }
//            cell.cityLabel.text = favorite.city
//            cell.countryLabel.text = favorite.country
            
            if self.favorites.isEmpty {
                let cell = UITableViewCell()
                
                let w = UIScreen.mainScreen().bounds.size.width
                var nw: CGFloat = 0
                var nh: CGFloat = 0
                var nx: CGFloat = 0
                var ny: CGFloat = 0
                if (w * 117.0 / 439.0) < 110.0 {
                    nw = w
                    nh = w * 117.0 / 439.0
                    nx = 0
                    ny = (110.0 - nh) / 2.0
                }else{
                    nw = 110.0 * 439.0 / 117.0
                    nh = 110.0
                    nx = (w - nw) / 2.0
                    ny = 0
                }
                let noFavoritesView = UIView(frame: CGRect(x: 0, y: 0, width: w, height: 110.0))
                noFavoritesView.backgroundColor = UIColor.whiteColor()
                let noFavoritesImageV = UIImageView(frame: CGRect(x: nx, y: ny, width: nw, height: nh))
                noFavoritesImageV.image = UIImage(named: "NoFavoritesYet")
                noFavoritesView.addSubview(noFavoritesImageV)
                
                cell.contentView.addSubview(noFavoritesView)
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesHorizontalScrollCell", forIndexPath: indexPath) as! FavoritesHorizontalScrollCell

                cell.favoriteScrollView.miniMarginPxBetweenItems = 5
                cell.favoriteScrollView.uniformItemSize = CGSizeMake(80, 80)
                
                //this must be called after changing any size or margin property of this class to get acurrate margin
                cell.favoriteScrollView.setItemsMarginOnce()
                
                var itemIndex = 0
                
                if cell.favoriteScrollView.items.count > 0 {
                    cell.favoriteScrollView.removeAllItems()
                }
                for favorite in self.favorites {
                    let itemView = UIView(frame: CGRectZero)
                    let itemButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                    itemButton.addTarget(self, action: #selector(self.favoriteItemTouchUp(_:)), forControlEvents: .TouchUpInside)
                    itemButton.tag = itemIndex
                    // AvatarImage
                    let itemAvatarImageV = ProfilePicture(frame: CGRect(x: 10, y: 0, width: 60, height: 60))
                    if let profileURL = favorite.pictureUrl {
                        itemAvatarImageV.sd_setImageWithURL(NSURL(string: profileURL), placeholderImage: UIImage(named: "default-profile"))
                    }else{
                        itemAvatarImageV.image = UIImage(named: "default-profile")
                    }
                    itemAvatarImageV.layer.cornerRadius = itemAvatarImageV.bounds.width / 2.0
    
                    itemAvatarImageV.clipsToBounds = true
                    
                    //First Name
                    let nameLabel = UILabel(frame: CGRect(x: 0, y: 60, width: 80, height: 20))
                    nameLabel.font = UIFont.init(name: "Myriad Pro", size: 15)
                    nameLabel.text = favorite.firstName
                    nameLabel.textAlignment = .Center
                    nameLabel.adjustsFontSizeToFitWidth = true
                    nameLabel.minimumScaleFactor = 0.3
    //                nameLabel.sizeToFit()
    //                nameLabel.backgroundColor = UIColor.darkGrayColor()
                    
                    itemView.addSubview(nameLabel)
                    itemView.addSubview(itemAvatarImageV)
                    itemView.addSubview(itemButton)
                    cell.favoriteScrollView.addItem(itemView)
                    
                    itemIndex += 1
                }
                
                return cell
            }
            
        }
        
    }
}
extension MessagesViewController: UITextViewDelegate {
    func contentSizeForTextView(textView: UITextView) -> CGSize {
        textView.layoutManager.ensureLayoutForTextContainer(textView.textContainer)
        
        let textBounds = textView.layoutManager.usedRectForTextContainer(textView.textContainer)
        let width = ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right)
        let height = ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom)
        
        return CGSizeMake(width, height)
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        textView.text = nil
        textView.textColor = UIColor.blackColor()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        return true
    }
}