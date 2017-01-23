//
//  UserDescriptionViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 23.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom

class UserDescriptionViewController: UIViewController {

    var userConfig = [String:AnyObject]()
    var userData = [String:AnyObject]()
    var user: UserModel?
    var edit:Bool = false
    var userDelegate: UserProfileDelegate?
    var summary:String?
    

    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var btn: UIButton!

    @IBOutlet weak var pitchTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo, let rect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            UIView.animateWithDuration(0.35, animations: {
                self.bottomViewConstraint.constant = rect.size.height
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.35, animations: {
            self.bottomViewConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UserDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDescriptionViewController.userDidAnswerToNotifications(_:)), name: "UserDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDescriptionViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDescriptionViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.pitchTextView.becomeFirstResponder()
        self.pitchTextView.hidden = true
        self.activityIndicator.startAnimating()
        
        if edit {
            self.btn.setTitle("SAVE", forState: UIControlState.Normal)
            self.activityIndicator.stopAnimating()
            self.pitchTextView.hidden = false
            if let txt = self.summary {
                self.pitchTextView.text = txt
            }
        } else {
            self.user!.industriesCode = self.userConfig["industries"] as? [Int]
            self.user!.offersCode = self.userConfig["offers"] as? [Int]
            self.user!.lookingsCode = self.userConfig["lookings"] as? [Int]
            self.closeBtn.enabled = false
            self.navigationItem.rightBarButtonItem = nil
            self.activityIndicator.stopAnimating()
            self.pitchTextView.hidden = false
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the user data to the next controller 
        if let vc = segue.destinationViewController as? StartDiscoveringViewController {
            vc.userData = nil
        }
    }

    func userDidAnswerToNotifications(notification: NSNotification) {
        if var user = self.user {
            if let deviceToken = notification.userInfo?["token"] as? NSString {
                user.deviceToken = deviceToken as String
            }
            user.summary = self.pitchTextView.text

            // 2.Send the data to the Lounjee API
            user.save(withCompletion: { (result, error) in
                if let id = result["id"] as? Int, let token = result["token"] as? String {
                    AnalyticsManager.identify("\(id)")
                    AnalyticsManager.people(["first_name": user.firstName!,
                        "last_name": user.lastName!,
                        "email": user.emailAddress!,
                        "country": user.country!, "industry": user.industry!])
                    
                    NSUserDefaults.standardUserDefaults().setInteger(id, forKey: "userId")
                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "lounjeeToken")
                    NSUserDefaults.standardUserDefaults().setObject(user.emailAddress, forKey: "emailAddress")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Get the next controller
                    if let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController {

                        dispatch_async(dispatch_get_main_queue(), {
                            vc.startDiscovering = true
                            vc.userData = UserModel(dictionary: result)
                            gCurrentUser = UserModel(dictionary: result)
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                            // Intercom Registration
                            if let emailAddress = gCurrentUser.emailAddress {
                                Intercom.registerUserWithUserId("\(id)", email: emailAddress)
                            }else{
                                Intercom.registerUserWithUserId("\(id)")
                            }
                        })
                    }
                }
            })
        }
    }
    
    @IBAction func nextButton(sender: AnyObject) {
        self.activityIndicator.startAnimating()

        if self.edit, let delegate = self.userDelegate {
            let userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
            let data = ["summary": self.pitchTextView.text]
            let patchUser = APIRouter.PatchUser(id: userId, data: data)
            
            APIManager.sendRequest(patchUser, withCompletion: { (result, error) in
                delegate.updateUser()
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        else {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
}


