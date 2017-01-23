//
//  DiscoveryViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 02.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//


protocol DiscoveryRequestDelegate {
    func meetActionDelegate()// Discovery
//    func meetActionDelegateForfavorite()// Matches
}

import UIKit
import KTCenterFlowLayout
import CoreLocation
import Intercom

class DiscoveryViewController: UIViewController, DiscoveryRequestDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var meetButton: UIButton!
    @IBOutlet weak var requestTextView: UITextView!
    
    @IBOutlet weak var requestViewEffect: UIVisualEffectView!
    @IBOutlet weak var keyboardAvoidingScrollView: UIScrollView!
    
    @IBOutlet weak var requestMatchView: UIView!
    
    @IBOutlet weak var requestCollectionView: UICollectionView!
    
    @IBOutlet weak var requestName: UILabel!
    @IBOutlet weak var requestProfilePicture: ProfilePicture!
    @IBOutlet weak var requestHeadline: UILabel!
    
    @IBOutlet weak var requestTitle: UILabel!
    
    var favoriteNotificationView: UIView!  // In app notification View
    var avatarImageV: ProfilePicture!      // In app notification avatar ImageView
    var descriptionLabel: UILabel!         // In app notification Label
    
    var lounjeeToken: String!
    var userId: Int!
    var potentialMatches = [UserModel]()
    
    var requestMatches = [RequestMatchModel]()
    
    var conversationMatches = [ConversationModel]()
    
    var currentMatchLookingFor = [String]()
    
    var favorites = [UserModel]()
    
    var isLoadedDiscory: Bool = false
    var isLoadedFavorite: Bool = false
    
    private var matchedArray = [Int]()
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo, let _ = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            UIView.animateWithDuration(0.35, animations: {
                self.bottomViewConstraint.constant = 120 // rect.size.height - 49
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.35, animations: {
            self.bottomViewConstraint.constant = 60.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func laterAction(sender: AnyObject) {
        self.ignoreMatch()
    }
    
    func meetActionDelegate() {
        self.dismissViewControllerAnimated(true, completion: {
            self.enableRequestView()
        })
    }
    
    @IBAction func meetAction(sender: AnyObject) {
        self.enableRequestView()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
        self.collectionView.hidden = true
        self.requestViewEffect.alpha = 0
        self.keyboardAvoidingScrollView.hidden = true
        
        self.lounjeeToken = NSUserDefaults.standardUserDefaults().objectForKey("lounjeeToken") as? String
        self.userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
        
        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DiscoveryViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DiscoveryViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        */
 
        self.laterButton.alpha = 0.0
        self.meetButton.alpha = 0.02
        
        isLoadedDiscory = false
        isLoadedFavorite = false
        
        if self.userId != 0 && self.lounjeeToken != nil {
            // Update the user location
            UserModel.updateLocation(self.userId) { (result, error) in
                
                DiscoveryModel.GetRequestedMatches { (result, error) in
                    self.requestMatches = result
                }
                
                // Get the potential matches
                DiscoveryModel.GetPotentialMatches({ (result, error) in
                // ConversationModel.getConversations ({ (result, error) in
            
                    self.potentialMatches = result
                    
                    var potentialMatchID = self.potentialMatches.count - 1
                    for potentialMatch in self.potentialMatches.reverse(){
                        
                        for requestUser in self.requestMatches{
                            if potentialMatch.id == requestUser.userId{
                                self.potentialMatches.removeAtIndex(potentialMatchID)
                            }
                        }
                        
                        potentialMatchID -= 1
                    }
                    
                    // Enable the view
                    dispatch_async(dispatch_get_main_queue(), {
                        UIView.animateWithDuration(0.2, animations: { 
                            self.noResultLabel.alpha = self.potentialMatches.count == 0 ? 1.0 : 0.0
                            self.collectionView.alpha = self.potentialMatches.count == 0 ? 0.0 : 1.0

                            self.laterButton.alpha = self.potentialMatches.count == 0 ? 0.0 : 1.0
                            self.meetButton.alpha = self.potentialMatches.count == 0 ? 0.0 : 1.0
                        })

                        self.isLoadedDiscory = true
                        if self.isLoadedFavorite == true {
                            self.collectionView.hidden = false
                            self.collectionView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                    })
                })
            
                FavoriteModel.GetFavorites { (result, error) in
                    self.favorites = result
                    dispatch_async(dispatch_get_main_queue(), {
                        self.isLoadedFavorite = true
                        if self.isLoadedDiscory == true {
                            self.collectionView.hidden = false
                            self.collectionView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                    })
                }                
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.requestMatchView.layer.cornerRadius = 5
        self.laterButton.layer.cornerRadius = 5.0
        self.meetButton.layer.cornerRadius = 5.0
    
        self.noResultLabel.alpha = 0.0
        self.laterButton.alpha = 0.0
        self.meetButton.alpha = 0.0
        
        self.collectionView.backgroundView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        if let layout = self.collectionView.collectionViewLayout as? DiscoveryCardsLayout {
            layout.layoutInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)// set the card size (collectionview frame - layoutinset)
            layout.delegate = self
        }
        
        // Add done button in TextView
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items = [
//            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelNumberPad")),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.doneWithKeyboard))]
        numberToolbar.sizeToFit()
        self.requestTextView.inputAccessoryView = numberToolbar
        
        // --
        self.initInAppNotification()
        
//        self.tabBarController?.tabBar.hidden = true
//        self.tabBarController?.tabBar.layer.zPosition = -1
//        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let currentCell = sender as? DiscoveryCollectionViewCell {
            if let vc = segue.destinationViewController as? UserProfileViewController {
                let user = getUserAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
                vc.userData = user
                vc.isRequest = true
                vc.requestDelegate = self
                vc.isFavorite = currentCell.favoriteButton.tag % 2 == 0 ? false: true
                
                // Track event to count the number of the swiped card
                Intercom.logEventWithName(NumberOfSeenFullProfile)
            }
        }
    }

    @IBAction func closeRequestMatchView(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            
            self.navigationController?.navigationBarHidden = false
            self.tabBarController?.tabBar.hidden = false
            self.extendedLayoutIncludesOpaqueBars = false
            self.edgesForExtendedLayout = UIRectEdge.None
            
            self.requestViewEffect.alpha = 0
            self.keyboardAvoidingScrollView.hidden = true
            
            self.requestTextView.resignFirstResponder()
            self.collectionView.reloadData()
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
    
    func doneWithKeyboard() {
        self.view.endEditing(true)
    }
    
    func enableRequestView(){
        
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.Bottom
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if let user = self.getUserAtIndexPath(indexPath) {

            if let offers = user.lookings {
                let labels = offers.map({ $0["label"]! })
                self.currentMatchLookingFor = labels as! [String]
                
                if let currentUser = gCurrentUser, let currentUser_LookingFor = currentUser.lookings {
                    let currentUser_labels = currentUser_LookingFor.map({ $0["label"]! })
                    self.configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
                
                self.requestCollectionView.reloadData()
            }
            
            self.requestProfilePicture.layer.cornerRadius = 35// CGRectGetWidth(self.requestProfilePicture.frame)/self.requestProfilePicture.borderRadius
            self.requestProfilePicture.clipsToBounds = true
            
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
            
            self.requestProfilePicture.layer.cornerRadius = 35// CGRectGetWidth(self.requestProfilePicture.frame)/self.requestProfilePicture.borderRadius
            self.requestProfilePicture.clipsToBounds = true

            if let headline = user.headline {
                self.requestHeadline.text = headline
            }
            
            UIView.animateWithDuration(0.3, animations: {
                self.requestViewEffect.alpha = 1
                self.keyboardAvoidingScrollView.hidden = false
            })
        }
    }
    
    func requestMatch(reason: String) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)

        if let user = getUserAtIndexPath(indexPath), let cell = self.collectionView.cellForItemAtIndexPath(indexPath) {
            
            // Track the events for number of the sent request
            Intercom.logEventWithName(NumberOfSentRequest)
            
            AnalyticsManager.track("Meeting Invite Sent", properties: ["Invited-UID": "\(user.id!)", "InviteTextEmpty": (reason.characters.count == 0)])
            
            DiscoveryModel.PostRequestMatch(user, reason: reason)
            view.endEditing(true)
            UIView.animateWithDuration(0.20, animations: {
                self.requestViewEffect.alpha = 0
                self.keyboardAvoidingScrollView.hidden = true
                
                cell.transform = CGAffineTransformMakeRotation(CGFloat(M_2_PI))
                cell.center = CGPointMake(2000.0, cell.center.y)
                }, completion: { (finished) in
                    self.potentialMatches.removeAtIndex(0)
                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
                    self.laterButton.alpha = self.potentialMatches.count > 0 ? 1.0 : 0.0
                    self.meetButton.alpha = self.potentialMatches.count > 0 ? 1.0 : 0.0
                    self.noResultLabel.alpha = self.potentialMatches.count > 0 ? 0.0 : 1.0
                    self.collectionView.alpha = self.potentialMatches.count == 0 ? 0.0 : 1.0
                    
                    self.navigationController?.navigationBarHidden = false
                    self.tabBarController?.tabBar.hidden = false
                    self.extendedLayoutIncludesOpaqueBars = false
                    self.edgesForExtendedLayout = UIRectEdge.None
                    
                    self.requestViewEffect.alpha = 0
                    self.keyboardAvoidingScrollView.hidden = true
                    
                    self.requestTextView.resignFirstResponder()
                    self.collectionView.reloadData()
            })
        }
    }
    
    func ignoreMatch() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        if let user = getUserAtIndexPath(indexPath), let cell = self.collectionView.cellForItemAtIndexPath(indexPath) {
            DiscoveryModel.PostIgnoreMatch(user.id!)
            
            UIView.animateWithDuration(0.20, animations: {
                cell.transform = CGAffineTransformMakeRotation(-CGFloat(M_2_PI))
                cell.center = CGPointMake(-2000.0, cell.center.y)
                }, completion: { (finished) in
                    self.potentialMatches.removeAtIndex(0)
                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
                    self.laterButton.alpha = self.potentialMatches.count > 0 ? 1.0 : 0.0
                    self.meetButton.alpha = self.potentialMatches.count > 0 ? 1.0 : 0.0
                    self.noResultLabel.alpha = self.potentialMatches.count > 0 ? 0.0 : 1.0
                    self.collectionView.alpha = self.potentialMatches.count == 0 ? 0.0 : 1.0
            })
        }
    }
    
    func getUserAtIndexPath(indexPath: NSIndexPath)-> UserModel? {
        let row = indexPath.row
        return self.potentialMatches[row]
    }
    
    func isFavoriteUser(currentUser: UserModel) -> Bool {
        for peer in self.favorites {
            if peer.linkedinId == currentUser.linkedinId {
                return true
            }
        }
        return false
    }
    
    // MARK:
    func configureWithData(data: [String], currentUser_data: [String]) {
        
        matchedArray.removeAll()
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10.0
            layout.minimumInteritemSpacing = 10.0
            layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        }
        
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

    @IBAction func handlePanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.collectionView)

        if let layout = self.collectionView.collectionViewLayout as? DiscoveryCardsLayout {
            if sender.state == .Began {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                layout.floatingCardIndexPath = indexPath
            }
            else if sender.state == .Ended {
                layout.floatingCardIndexPath = nil
                return
            }

            layout.floatingCardCenterPosition = CGPointMake(layout.floatingCardCenterPosition.x + translation.x, layout.floatingCardCenterPosition.y + translation.y)
            layout.invalidateLayout()

            if let cell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? DiscoveryCollectionViewCell {
                if cell.center.x < UIScreen.mainScreen().bounds.width / 2.0 - 40.0 {
                    cell.meetImageView.hidden = true
                    cell.laterImageView.hidden = false
                    cell.meetView.hidden = true
                    cell.laterView.hidden = false
                }
                else if cell.center.x > UIScreen.mainScreen().bounds.width / 2.0 + 40.0 {
                    cell.meetImageView.hidden = false
                    cell.laterImageView.hidden = true
                    cell.meetView.hidden = false
                    cell.laterView.hidden = true
                }
                else {
                    cell.meetImageView.hidden = true
                    cell.laterImageView.hidden = true
                    cell.meetView.hidden = true
                    cell.laterView.hidden = true
                }
            }
        }
        sender.setTranslation(CGPointZero, inView: self.collectionView)
    }
    
    // MARK: Favorite Feature
    
    @IBAction func favoriteTouchUp(sender: UIButton) {
        
        self.activityIndicator.startAnimating()
//        let userIndex = sender.tag / 2
        if let currentUser = self.potentialMatches[0] as UserModel? {
            if sender.tag % 2 == 0 {// if it is unfavorite, set it to favorite
                
                // Track the events for number of the favorite users
                Intercom.logEventWithName(NumberOfFavoritedUsers)
                
                let postFavorite = APIRouter.PostFavorite(favoriteUserID: (currentUser.id)!)
                APIManager.sendRequest(postFavorite, withCompletion: { (result, error) in
                    var response = [String: AnyObject]()
                    response = result
                    if response.count > 2 {
                        dispatch_async(dispatch_get_main_queue(), {
//                            self.tabBarController?.tabBar.hidden = true
                            
                            sender.setBackgroundImage(UIImage(named: "icon-favorite"), forState: UIControlState.Normal)
                            sender.tag += 1
                            
                            self.setInfoInAppNotification(currentUser)
                            self.showInAppNotification()
                            
                            AnalyticsManager.track("Favorite User", properties: ["Favorite User - UID": "\(currentUser.id)"])
                        })
                    }
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.activityIndicator.stopAnimating()
                    })
                })
            }else{
                let deleteFavorite = APIRouter.DeleteFavorite(favoriteUserID: (currentUser.id)!)
                APIManager.sendRequest(deleteFavorite, withCompletion: { (result, error) in
                    print("\(result)")
                })
                sender.setBackgroundImage(UIImage(named: "icon-unfavorite"), forState: UIControlState.Normal)
                sender.tag -= 1
                self.activityIndicator.stopAnimating()
            }
        }
    }
    // MARK: In app notification
    func initInAppNotification() {
        let w = UIScreen.mainScreen().bounds.size.width
//        let h = UIScreen.mainScreen().bounds.size.height
        
        self.favoriteNotificationView = UIView(frame: CGRect(x: 0, y: -80, width: w, height: 80))
        self.favoriteNotificationView.backgroundColor = UIColor(red: 247.0 / 255.0, green: 218.0 / 255.0, blue: 7.0 / 255.0, alpha: 1)
        
        self.avatarImageV = ProfilePicture(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        self.avatarImageV.layer.cornerRadius = self.avatarImageV.bounds.width / 2.0
        self.avatarImageV.layer.borderColor = self.avatarImageV.borderColor.CGColor
        self.avatarImageV.layer.borderWidth = 2//self.avatarImageV.borderWidth
        self.avatarImageV.clipsToBounds = true
    
        self.descriptionLabel = UILabel(frame: CGRect(x: 80, y: 10, width: w - 80, height: 60))
        self.descriptionLabel.textAlignment = .Left
        self.descriptionLabel.textColor = UIColor.whiteColor()
        
        let inAppButton = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: 80))
        inAppButton .addTarget(self, action: #selector(self.inAppButtonTouchUp(_:)), forControlEvents: .TouchUpInside)
        
        self.favoriteNotificationView.addSubview(self.avatarImageV)
        self.favoriteNotificationView.addSubview(self.descriptionLabel)
        self.favoriteNotificationView.addSubview(inAppButton)
        
        self.favoriteNotificationView.alpha = 0
        self.favoriteNotificationView.hidden = true
        
        self.view.addSubview(self.favoriteNotificationView)
    }
    
    func setInfoInAppNotification(currentUser: UserModel) {
        if let profileURL = currentUser.pictureUrl {
            self.avatarImageV.sd_setImageWithURL(NSURL(string: profileURL), placeholderImage: UIImage(named: "default-profile"))
        }else{
            self.avatarImageV.image = UIImage(named: "default-profile")
        }
        
        var attributedStr = NSMutableAttributedString()
        let str = "\(currentUser.firstName!) is in your Favorites"
        attributedStr = NSMutableAttributedString(string: str, attributes: [NSFontAttributeName: UIFont.init(name: "Myriad Pro", size: 18.0)!])
        attributedStr.addAttributes([NSFontAttributeName: UIFont.init(name: "MyriadPro-Semibold", size: 18)!], range: NSRange(location: 0, length: (currentUser.firstName?.characters.count)!))
        self.descriptionLabel.attributedText = attributedStr
    }
    
    func showInAppNotification() {
        self.navigationController?.navigationBarHidden = true
        self.topCollectionViewConstraint.constant = 44
        self.collectionView.setNeedsLayout()
        self.favoriteNotificationView.hidden = false
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
            self.favoriteNotificationView.frame = CGRect(x: 0, y: 0, width: self.favoriteNotificationView.frame.size.width, height: self.favoriteNotificationView.frame.size.height)
            self.favoriteNotificationView.alpha = 1
            }) { (isFinished) in
                let delay = 3 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    // After 2 seconds this line will be executed
                    UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
                        self.favoriteNotificationView.alpha = 0
                        self.favoriteNotificationView.frame = CGRect(x: 0, y: -self.favoriteNotificationView.frame.size.width, width: self.favoriteNotificationView.frame.size.width, height: self.favoriteNotificationView.frame.size.height)
                        }, completion: { (isFinished) in
                            self.favoriteNotificationView.hidden = true
                            
                            self.navigationController?.navigationBarHidden = false
                            self.topCollectionViewConstraint.constant = 0
                            self.collectionView.setNeedsLayout()
//                            self.tabBarController?.tabBar.hidden = false
                    })
                }
        }
    }
    
    func inAppButtonTouchUp(sender: UIButton) {
        self.tabBarController?.selectedIndex = 1;
    }
}

// MARK: Extention

extension DiscoveryViewController: DiscoveryCardsLayoutDelegate {
    func discoveryCardsLayout(layout: DiscoveryCardsLayout, didDragCardOverLimitOnDirection direction: DiscoveryCardsLayoutDirection, indexPath: NSIndexPath) {
    }

    func discoveryCardsLayoutDidFinishDragging(layout: DiscoveryCardsLayout, onDirection direction: DiscoveryCardsLayoutDirection, indexPath: NSIndexPath) {
        switch direction {
            case .Left:
                if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? DiscoveryCollectionViewCell {
                    cell.meetImageView.hidden = true
                    cell.laterImageView.hidden = false
                    cell.meetView.hidden = true
                    cell.laterView.hidden = false
                }
                
                self.collectionView.performBatchUpdates({
                    layout.offsetFloatingCardAtIndexPath(indexPath, inDirection: direction)
                    }, completion: nil)
                
                self.ignoreMatch()
                
                // Track event to count the number of the swiped card
                Intercom.logEventWithName(NumberOfSwipedCard)//, metaData: ["Step": "1"])
                break
            
            case .Right:
                if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? DiscoveryCollectionViewCell {
                    cell.meetImageView.hidden = false
                    cell.laterImageView.hidden = true
                    cell.meetView.hidden = false
                    cell.laterView.hidden = true
                }
                
                self.collectionView.performBatchUpdates({
                    layout.offsetFloatingCardAtIndexPath(indexPath, inDirection: direction)
                    }, completion: nil)
                
                self.enableRequestView()
                
                // Track event to count the number of the swiped card
                Intercom.logEventWithName(NumberOfSwipedCard)//, metaData: ["Step": "1"])
                break
            
            default:
                if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? DiscoveryCollectionViewCell {
                    cell.meetImageView.hidden = true
                    cell.laterImageView.hidden = true
                    cell.meetView.hidden = true
                    cell.laterView.hidden = true
                }

                self.collectionView.performBatchUpdates({
                    layout.offsetFloatingCardAtIndexPath(indexPath, inDirection: direction)
                }, completion: nil)
            }
    }
}

extension DiscoveryViewController: UICollectionViewDelegate{
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

extension DiscoveryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.requestCollectionView {
            return self.currentMatchLookingFor.count
        }
        return self.potentialMatches.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == self.requestCollectionView {
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
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DiscoveryCollectionViewCell
        cell.layoutIfNeeded()

        cell.profileImgView.layer.cornerRadius = cell.profileImgView.bounds.width / 2.0
        cell.profileImgView.layer.borderColor = cell.profileImgView.borderColor.CGColor
        cell.profileImgView.layer.borderWidth = cell.profileImgView.borderWidth
        
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha:1.0).CGColor
        cell.layer.cornerRadius = 8.0
        cell.clipsToBounds = true
        
        cell.meetImageView.hidden = true
        cell.laterImageView.hidden = true
        cell.meetView.hidden = true
        cell.laterView.hidden = true

        if let user = self.getUserAtIndexPath(indexPath) {
            AnalyticsManager.track("Viewed Profile", properties: ["Viewed Profile - UID": "\(user.id!)"])
            
            // Favorite Button Check
            if self.isFavoriteUser(user) {
                cell.favoriteButton.tag = indexPath.row * 2 + 1
                cell.favoriteButton.setBackgroundImage(UIImage(named: "icon-favorite"), forState: UIControlState.Normal)
            }else{
                cell.favoriteButton.tag = indexPath.row * 2
                cell.favoriteButton.setBackgroundImage(UIImage(named: "icon-unfavorite"), forState: UIControlState.Normal)
            }
            
            if gCurrentUser != nil{
                
                var myLocation = CLLocation(latitude: 0.0, longitude: 0.0)
                if gCurrentUser.latitude != nil && gCurrentUser.longitude != nil{
                    myLocation = CLLocation(latitude: gCurrentUser.latitude!, longitude: gCurrentUser.longitude!)
                }
                
                var userLocation = CLLocation(latitude: 0.0, longitude: 0.0)
                if user.latitude != nil && user.longitude != nil{
                    userLocation = CLLocation(latitude: (user.latitude)!, longitude: (user.longitude)!)
                }
                
                //Measuring my distance to my buddy's (in km)
                let distance = myLocation.distanceFromLocation(userLocation) / 1000
                
                //Display the result in km
                let distanceString = String(format: "%.01fkm", distance)
                
                cell.iconLocation.hidden = false
                cell.distanceLabel.text = distanceString
                
            }

            if let name = user.lastName, let firstname = user.firstName {
                cell.nameLabel.text = firstname + " " + name
            }
            
            if let industries = user.industries {
                let labels = industries.map({ $0["description"]! })
                cell.industries = labels as! [String]
                
                if let currentUser = gCurrentUser, let currentUser_industries = currentUser.industries{
                    let currentUser_labels = currentUser_industries.map({ $0["description"]! })
                    
                    cell.configureWithIndustryData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
            }

            if let offers = user.offers {
                let labels = offers.map({ $0["label"]! })
                cell.offers = labels as! [String]
                
                if let currentUser = gCurrentUser, let currentUser_offers = currentUser.offers{
                    let currentUser_labels = currentUser_offers.map({ $0["label"]! })
                        
                    cell.configureWithOfferData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
            }
            
            if let lookings = user.lookings {
                let labels = lookings.map({ $0["label"]! })
                cell.lookings = labels as! [String]
                
                if let currentUser = gCurrentUser, let currentUser_lookings = currentUser.lookings{
                    let currentUser_labels = currentUser_lookings.map({ $0["label"]! })
                    
                    cell.configureWithLookingData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
            }

            let placeholder = UIImage(named: "default-profile")
            cell.userBanner.image = placeholder
            cell.profileImgView.image = placeholder

            if let profileImg = user.pictureUrl {
                let url = NSURL(string: profileImg)!
                cell.userBanner.sd_setImageWithURL(url, placeholderImage: UIImage(named: "default-profile"))
                cell.profileImgView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "default-profile"))
            }
            
            cell.statusLabel.text = user.headline
            //cell.summaryLabel.text = user.summary
            //if let distance = user.distance {
            //    cell.distanceLabel.text = "\(distance) Km"
            //    cell.distanceLabel.hidden = false
            //    cell.iconLocation.hidden = false
            //} else {
            //    cell.distanceLabel.hidden = true
            //    cell.iconLocation.hidden = true
            //}
        }
        return cell
    }
}

extension DiscoveryViewController: UITextViewDelegate {
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