//
//  UserProfileViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 18.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import KTCenterFlowLayout
import CoreLocation
import Intercom
//import MixPanel

protocol UserProfileDelegate {
    func updateUser()
}

class UserProfileViewController: UIViewController, UserProfileDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var profilePicture: ProfilePicture!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dissmissButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var iconLocation: UIImageView!
    @IBOutlet weak var userBanner: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var heightBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightEditBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightStatusLabelConstraint: NSLayoutConstraint!
    
    var favoriteNotificationView: UIView!  // In app notification View
    var avatarImageV: ProfilePicture!      // In app notification avatar ImageView
    var descriptionLabel: UILabel!         // In app notification Label
    
    var userId:Int = NSUserDefaults.standardUserDefaults().integerForKey("userId")
    internal var userData:UserModel?
    
    var editable:Bool = false
    var startDiscovering:Bool = false
    var alreadyConnected: Bool = false
    
    var isRequest:Bool = false
    var isFavorite:Bool = false
    var requestDelegate:DiscoveryRequestDelegate?
    
    var cellColor: UIColor!
    var cellUnmatchedColor: UIColor!
    
    private var data = [String]()
    private var currentUser_data = [String]()
    
    private var matchedArray = [Int]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.userTableView.hidden = true
        self.heightBtnConstraint.constant = 0
        self.heightEditBtnConstraint.constant = 0
        
        self.dissmissButton.hidden = false
        
        self.editButton.hidden = true
        self.favoriteButton.hidden = true
        
        self.cellColor = UIColor.whiteColor()
        if let receiver = self.userData, let industries = receiver.industries {
            let labels = industries.map({ $0["description"]! })
            
            if let currentUser = gCurrentUser, let currentUser_industries = currentUser.industries{
                let currentUser_labels = currentUser_industries.map({ $0["description"]! })
                
                configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
            }
        }
        
        if self.startDiscovering || self.isRequest {
            self.startButton.hidden = false
            self.startButton.backgroundColor = UIColor(red: 102/255.0, green: 160/255.0, blue: 64/255.0, alpha: 1.0)
            
            self.heightBtnConstraint.constant = 60
            
            if self.isRequest {
                self.startButton.setTitle("LET'S MEET", forState: .Normal)
                
            } else {
                self.dissmissButton.hidden = true
                self.navigationItem.setHidesBackButton(true, animated:true)
            }
        }
        
        if self.alreadyConnected {
            self.startButton.hidden = false
            
            self.startButton.backgroundColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
            
            self.heightBtnConstraint.constant = 60
            
            self.startButton.setTitle("SEND MESSAGE", forState: .Normal)
        }
        
        if self.editable == true{
            
            self.heightBtnConstraint.constant = 0
            
            self.startButton.hidden = true
            self.distanceLabel.hidden = true
            self.iconLocation.hidden = true
            
            self.heightEditBtnConstraint.constant = 25
            self.editButton.hidden = false
            self.favoriteButton.hidden = true
        }else{
            self.favoriteButton.hidden = false
            if self.isFavorite {
                self.favoriteButton.tag = 1
                self.favoriteButton.setBackgroundImage(UIImage(named: "icon-favorite"), forState: UIControlState.Normal)
            }else{
                self.favoriteButton.tag = 0
                self.favoriteButton.setBackgroundImage(UIImage(named: "icon-unfavorite"), forState: UIControlState.Normal)
            }
        }
        
        self.view.layoutIfNeeded()
        
        // If the userdata is not set yet, request the API
        if userData == nil {
            
            UserModel.fetch(self.userId) { (result, error) in
                self.userData = result

                if (self.isRequest) {
                    AnalyticsManager.track("Viewed Full Profile", properties: ["Viewed Full Profile - UID": "\(self.userData!.id!)"])
                }

                dispatch_async(dispatch_get_main_queue(), {
                    self.dataDidLoad()
                })
            }
        } else {
            if (self.isRequest) {
                AnalyticsManager.track("Viewed Full Profile", properties: ["Viewed Full Profile - UID": "\(self.userData!.id!)"])
            }
            self.dataDidLoad()
        }
        
        self.view.layoutIfNeeded()
        self.userTableView.reloadData()
        self.view.layoutIfNeeded()
        
        self.loader.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        self.initInAppNotification()
        
        self.dissmissButton.tintColor = UIColor.whiteColor()
        self.profilePicture.layer.cornerRadius = UIScreen.mainScreen().bounds.size.height * 130.0 / (600.0 * self.profilePicture.borderRadius)
        self.profilePicture.layer.borderColor = self.profilePicture.borderColor.CGColor
        self.profilePicture.layer.borderWidth = self.profilePicture.borderWidth
        
        self.userTableView.estimatedRowHeight = 180
        self.userTableView.rowHeight = UITableViewAutomaticDimension
        self.userTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 62.0, 0.0)
        
        self.editButton.addTarget(self, action: #selector(UserProfileViewController.buttonClickedIndustry(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        //let distanceInMeters = locationFrom.distanceFromLocation(locationTo)
        
        //My location
        
        if gCurrentUser != nil{
            var myLocation = CLLocation(latitude: 0.0, longitude: 0.0)
            if gCurrentUser.latitude != nil && gCurrentUser.longitude != nil{
                myLocation = CLLocation(latitude: gCurrentUser.latitude!, longitude: gCurrentUser.longitude!)
            }
            
            var userLocation = CLLocation(latitude: 0.0, longitude: 0.0)
            if self.userData?.latitude != nil && self.userData?.longitude != nil{
                userLocation = CLLocation(latitude: (self.userData?.latitude)!, longitude: (self.userData?.longitude)!)
            }
            
            //Measuring my distance to my buddy's (in km)
            let distance = myLocation.distanceFromLocation(userLocation) / 1000
            
            //Display the result in km
            let distanceString = String(format: "%.01fkm", distance)
            
            self.iconLocation.hidden = false
            self.distanceLabel.text = distanceString
        }
        
        //if let distance = self.userData?.distance {
        //    self.iconLocation.hidden = false
        //    self.distanceLabel.hidden = false
        //    self.distanceLabel.text = "\(distance) Km"
        //} else {
        //    self.iconLocation.hidden = true
        //    self.distanceLabel.hidden = true
        //}
        
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        
        self.collectionView.collectionViewLayout = layout
        
        self.collectionView.userInteractionEnabled = true
        self.collectionView.scrollEnabled = true
        self.collectionView.showsVerticalScrollIndicator = true
        self.collectionView.showsHorizontalScrollIndicator = true
//        self.collectionView.backgroundColor = UIColor.clearColor()
        
        self.topView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height * 3 / 5)
        self.topView.layoutIfNeeded()
        
        self.view.layoutIfNeeded()
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dissmissButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func startDiscovering(sender: AnyObject) {
        if self.isRequest, let delegate = self.requestDelegate {
            delegate.meetActionDelegate()
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(StartDiscoveringViewController.validationNotificationName, object: self)
        }
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        if self.alreadyConnected{
            //let vcChat = self.storyboard!.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            
            //self.presentViewController(vcChat, animated: true, completion: nil)
            self.dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    // MARK: Favorite Button Touch Up
    @IBAction func favoriteTouchUp(sender: UIButton) {
//        print("Current User ID: \(self.userData?.id)")
        self.loader.startAnimating()
        
        if sender.tag == 0 {// Add Favorite
            
            // Track the events for number of the favorite users
            Intercom.logEventWithName(NumberOfFavoritedUsers)
            
            let postFavorite = APIRouter.PostFavorite(favoriteUserID: (self.userData?.id)!)
            APIManager.sendRequest(postFavorite, withCompletion: { (result, error) in
                var response = [String: AnyObject]()
                response = result
                if response.count > 2 {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.favoriteButton.setBackgroundImage(UIImage(named: "icon-favorite"), forState: UIControlState.Normal)
                        sender.tag = 1
                        
                        // Show in app notification
                        self.setInfoInAppNotification(self.userData!)
                        self.showInAppNotification()
                        
                        AnalyticsManager.track("Favorite User", properties: ["Favorite User - UID": "\(self.userData?.id)"])
                    })
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.loader.stopAnimating()
                })
            })
            
        }else{// Delete Favorite
            
            let deleteFavorite = APIRouter.DeleteFavorite(favoriteUserID: (self.userData?.id)!)
            APIManager.sendRequest(deleteFavorite, withCompletion: { (result, error) in
                print("\(result)")
            })
            self.favoriteButton.setBackgroundImage(UIImage(named: "icon-unfavorite"), forState: UIControlState.Normal)
            sender.tag = 0
            self.loader.stopAnimating()
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
        self.avatarImageV.layer.borderWidth = self.avatarImageV.borderWidth
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
        self.favoriteNotificationView.hidden = false
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
            self.favoriteNotificationView.frame = CGRect(x: 0, y: 0, width: self.favoriteNotificationView.frame.size.width, height: self.favoriteNotificationView.frame.size.height)
            self.favoriteNotificationView.alpha = 1
        }) { (isFinished) in
            let delay = 2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                // After 2 seconds this line will be executed
                UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
                    self.favoriteNotificationView.alpha = 0
                    self.favoriteNotificationView.frame = CGRect(x: 0, y: -self.favoriteNotificationView.frame.size.width, width: self.favoriteNotificationView.frame.size.width, height: self.favoriteNotificationView.frame.size.height)
                    }, completion: { (isFinished) in
                        self.favoriteNotificationView.hidden = true
                })
            }
        }
    }
    
    func inAppButtonTouchUp(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
        
//        self.tabBarController?.selectedIndex = 1;
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.switchRootViewController()
    }
    
    // MARK:
    func configureWithData(data: [String], currentUser_data: [String]) {
        
        matchedArray.removeAll()
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10.0
            layout.minimumInteritemSpacing = 10.0
            layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        }
        
        self.data = data
        self.currentUser_data = currentUser_data
        
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
//        var testMatched = matchedArray
//        var testData = self.data
        var index: Int = 0
        for statusItem in matchedArray {
            if statusItem == 1 {
                matchedArray.removeAtIndex(index)
                matchedArray.insert(1, atIndex: 0)
                let datum = self.data[index]
                self.data.removeAtIndex(index)
                self.data.insert(datum, atIndex: 0)
            }
            
            index += 1
        }
        
//        testMatched = matchedArray
//        testData = self.data
        
        self.collectionView.reloadData()
        //self.collectionViewHeight.constant = self.collectionView?.collectionViewLayout.collectionViewContentSize().height ?? 0.0
    }
    
    func updateUser() {

        UserModel.fetch(self.userId, withCompletion: { (result, error) in
            self.userData = result
            
            self.userData?.pictureUrl = gCurrentUser.pictureUrl
            
            gCurrentUser = result
            gCurrentUser.pictureUrl = self.userData?.pictureUrl
            
//          let string = NSUserDefaults.standardUserDefaults().objectForKey("pictureURL") as? String
//          if string != nil{
//              gCurrentUser.pictureUrl = NSUserDefaults.standardUserDefaults().objectForKey("pictureURL") as? String
//          }
            var fullName: String = ""
            
            if let firstName = gCurrentUser.firstName {
                fullName = firstName + " "
            }
            if let lastName = gCurrentUser.lastName {
                fullName += lastName
            }
            
            Intercom.updateUserWithAttributes(["name": fullName])
            
            dispatch_async(dispatch_get_main_queue(), {
                self.dataDidLoad()
            })
        })
        
    }
    
    func dataDidLoad() -> Void {
        if let firstname = self.userData?.firstName, let lastname = self.userData?.lastName, let headline = self.userData?.headline {
            self.nameLabel.text = firstname + " " + lastname
            self.statusLabel.text = headline
            
            // check number of lines in status label
            let drawingRect = self.statusLabel.textRectForBounds(self.statusLabel.frame, limitedToNumberOfLines: self.statusLabel.numberOfLines)
            let lineCount = drawingRect.height / self.statusLabel.font.lineHeight
            if lineCount < 2 {
                self.heightStatusLabelConstraint.constant = self.statusLabel.frame.size.height / 2
            }
            
        }

        if let profile = self.userData?.pictureUrl {
            self.profilePicture.sd_setImageWithURL(NSURL(string: profile)!,placeholderImage:UIImage(named: "default-profile"))
            self.userBanner.sd_setImageWithURL(NSURL(string: profile)!, placeholderImage: UIImage(named: "default-profile"))
        }

        self.loader.hidden = true
        self.userTableView.hidden = false
        self.userTableView.reloadData()
        
        if let receiver = self.userData, let industries = receiver.industries {
            let labels = industries.map({ $0["description"]! })
            
            if let currentUser = gCurrentUser, let currentUser_industries = currentUser.industries{
                let currentUser_labels = currentUser_industries.map({ $0["description"]! })
                
                configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
            }
        }
        
        self.collectionView.reloadData()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "linkedinProfileSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.topViewController as! WebDetailsViewController

            if let url = userData?.publicProfileUrl {
                vc.request = NSURLRequest(URL: NSURL(string: url)!)
                vc.isModal = true
            }
            else{
                let alertView = UIAlertView(title: "Warning", message: "This user doesn't have linked in profile now.", delegate: nil, cancelButtonTitle: "OK" )
                alertView.show()
                
                let url = "https://www.linkedin.com"
                vc.request = NSURLRequest(URL: NSURL(string: url)!)
                vc.isModal = true
                
                return
            }
        }
    }
    
    func buttonClickedIndustry(sender:UIButton) {
        let vc1 = self.storyboard!.instantiateViewControllerWithIdentifier("NewUserPreferencesViewController") as! NewUserPreferencesViewController
        
        vc1.userDelegate = self
        vc1.navigationTitle.title = "Select your industries"
        vc1.edit = true
        vc1.tag = 1
        vc1.user = self.userData!
        
        let navController1 = LounjeeNavigationController(rootViewController: vc1)
        
        self.presentViewController(navController1, animated: true, completion: nil)
        
    }
    
    func buttonClicked(sender:UIButton) {
        if let superview = sender.superview?.superview as? UITableViewCell {
            if let indexPath = self.userTableView.indexPathForCell(superview) {
                let vc1 = self.storyboard!.instantiateViewControllerWithIdentifier("NewUserPreferencesViewController") as! NewUserPreferencesViewController
                vc1.userDelegate = self
                vc1.edit = true
                vc1.tag = indexPath.section
                vc1.user = self.userData!
                
                let vc2 = self.storyboard!.instantiateViewControllerWithIdentifier("UserDescriptionViewController") as! UserDescriptionViewController
                vc2.edit = true
                
                let navController1 = LounjeeNavigationController(rootViewController: vc1)
                let navController2 = LounjeeNavigationController(rootViewController: vc2)
                
                // Industries
                //if indexPath.section == 0 && indexPath.row == 0 {
                //    vc1.navigationTitle.title = "Select your industries"
                //    vc1.tag = 1
                //    self.presentViewController(navController1, animated: true, completion: nil)
                //}
                    
                // Summary
                if indexPath.section == 0 && indexPath.row == 0 {
                    vc2.userDelegate = self
                    if let summary = self.userData?.summary {
                        vc2.summary = summary
                    }
                    self.presentViewController(navController2, animated: true, completion: nil)
                }
                    
                // Lookings
                if indexPath.section == 1 {
                    vc1.navigationTitle.title = "What are you looking for?"
                    vc1.tag = 2
                    self.presentViewController(navController1, animated: true, completion: nil)
                 }
                    
                // Offers
                if indexPath.section == 2 {
                    vc1.navigationTitle.title = "What do you have to offer?"
                    vc1.tag = 3
                    self.presentViewController(navController1, animated: true, completion: nil)
                }
            }
            
        }
        
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension UserProfileViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView

        header.textLabel!.font = UIFont.init(name: "MyriadPro-Cond", size: 18)
        header.textLabel!.textColor = UIColor.lightGrayColor()
    }
    
    /*func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as! LabelTableViewCell
                
                if let receiver = self.userData, let industries = receiver.industries {
                    let labels = industries.map({ $0["description"]! })
                    cell.configureWithData(labels as! [String])
                }
                
                let height = cell.collectionView.collectionViewLayout.collectionViewContentSize().height
                return height + 20
            case 1: return 40
            default: return 0
                
            }
        }
        
        switch indexPath.section {
        case 1:
            
            let cell =  tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as! LabelTableViewCell
            
            if let receiver = self.userData, let lookings = receiver.lookings {
                let labels = lookings.map({ $0["label"]! })
                cell.configureWithData(labels as! [String])
            }
            
            let height = cell.collectionView.collectionViewLayout.collectionViewContentSize().height
            return height + 20
        case 2:
            let cell =  tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as! LabelTableViewCell
            
            if let receiver = self.userData, let offers = receiver.offers {
                let labels = offers.map({ $0["label"]! })
                cell.configureWithData(labels as! [String])
            }
            
            let height = cell.collectionView.collectionViewLayout.collectionViewContentSize().height
            return height + 20
        case 3:
            return 40
        default:
            return 0
        }
        
    }*/

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if section == 0 {
        //    return 2
        //}
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*if indexPath.section == 0{
                    }*/
            
        if indexPath.section == 0 {
            switch indexPath.row {
            /*case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as! LabelTableViewCell
                
                if let receiver = self.userData, let industries = receiver.industries {
                    let labels = industries.map({ $0["description"]! })
                    
                    if let currentUser = gCurrentUser, let currentUser_industries = gCurrentUser.industries{
                        let currentUser_labels = currentUser_industries.map({ $0["description"]! })
                        
                        cell.configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                    }
                }
                
                cell.editable = self.editable
                cell.editButton.tag = 1
                cell.editButton.addTarget(self, action: #selector(UserProfileViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.cellColor = UIColor(red: 185/255.0, green: 60/255.0, blue: 57/255.0, alpha: 1.0)
                
                
                
                return cell*/

            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as! SummaryTableViewCell

                if self.editable == true{
                    cell.editable = true
                }
                else{
                    cell.editable = false
                }
                
                if let summary = self.userData?.summary {
                    
                    if summary.compare("") == NSComparisonResult.OrderedSame{
                        cell.summaryLabel.text = "Summary not available"
                    }
                    else{
//                        cell.summaryLabel.text = summary
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 8
                        
                        let attrString = NSMutableAttributedString(string: summary)
                        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                        cell.summaryLabel.attributedText = attrString
                    }
                    
                    //cell.editable = self.editable
                    cell.editButton.tag = 4
                    cell.editButton.addTarget(self, action: #selector(UserProfileViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                else{
                    cell.summaryLabel.text = "Summary not available"
                    
                }
                return cell
            default:
                return tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)
            }
        }
        switch indexPath.section {
        case 1:
            let cell =  tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as! LabelTableViewCell
            
            if let receiver = self.userData, let lookings = receiver.lookings {
                let labels = lookings.map({ $0["label"]! })
                
                if let currentUser = gCurrentUser, let currentUser_lookings = currentUser.lookings{
                    let currentUser_labels = currentUser_lookings.map({ $0["label"]! })
                    
                    cell.configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
            }
            
            //cell.editable = self.editable
            if self.editable == true{
                cell.editable = true
            }
            else{
                cell.editable = false
            }
            
            cell.editButton.tag = 3
            cell.editButton.addTarget(self, action: #selector(UserProfileViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.cellColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
            return cell
        case 2:
            let cell =  tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as! LabelTableViewCell
            
            if let receiver = self.userData, let offers = receiver.offers {
                let labels = offers.map({ $0["label"]! })
                
                if let currentUser = gCurrentUser, let  currentUser_offers = currentUser.offers{
                    let currentUser_labels = currentUser_offers.map({ $0["label"]! })
                    
                    cell.configureWithData(labels as! [String], currentUser_data: currentUser_labels as! [String])
                }
            }
            
            //cell.editable = self.editable
            if self.editable == true{
                cell.editable = true
            }
            else{
                cell.editable = false
            }
            
            cell.editButton.tag = 2
            cell.editButton.addTarget(self, action: #selector(UserProfileViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.cellColor = UIColor(red: 32/255.0, green: 55/255.0, blue: 86/255.0, alpha: 1.0)
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("linkedinProfileCell", forIndexPath: indexPath) as! LinkedinProfileTableViewCell

            if let userProfile = self.userData?.publicProfileUrl {
                cell.urlLabel.text = userProfile
            }
            else{
                cell.urlLabel.text = ""
            }
            
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch  section {
        case 1:
            return "WHAT I AM LOOKING FOR"
        case 2:
            return "WHAT I CAN OFFER"
        case 3:
            return "LINKEDIN PROFILE"
        default:
            return ""
        }
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let label = UILabel()
        
        //label.font = UIFont(name: "MyriadPro-SemiBold", size: 12)
        label.font = UIFont.init(name: "MyriadPro-SemiBold", size: 12.0)
        
        label.text = self.data[indexPath.row].uppercaseString
        label.sizeToFit()
        return CGSizeMake(label.bounds.width + 10.0, 22.0)
    }
    
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        /*let CellWidth = 73
        let CellCount = self.data.count
        let CellSpacing = 10
        let collectionViewWidth = 240.0
        
        let totalCellWidth = CellWidth * CellCount
        let totalSpacingWidth = CellSpacing * (CellCount - 1)
        
        let leftInset = (collectionViewWidth - totalCellWidth + totalSpacingWidth) / 2;
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset) */
    //    return UIEdgeInsetsMake(0, 10, 0, 10)
    //}
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! InterestCollectionViewCell
        
        if matchedArray[indexPath.row] == 1{
            cell.backgroundColor = UIColor.whiteColor()
            cell.interestLabel.textColor = UIColor.init(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0)
            cell.layer.borderColor = UIColor.init(red: 61/255, green: 61/255, blue: 61/255, alpha: 1.0).CGColor
        }
        else{
            cell.backgroundColor = UIColor.clearColor()
            cell.interestLabel.textColor = UIColor.whiteColor()
            
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        //cell.backgroundColor = self.cellColor
        cell.interestLabel.textAlignment = .Center
        cell.interestLabel.text = self.data[indexPath.row].uppercaseString
        return cell
    }
}