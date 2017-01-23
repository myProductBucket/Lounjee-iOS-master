//
//  LounjeeTabBarController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 09.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom

class LounjeeTabBarController: UITabBarController {
    
    var lounjeeToken: String!
    var userId: Int!
    
    func userDidAnswerToNotifications(notification: NSNotification) {
        if let userId = self.userId, let deviceToken = notification.userInfo?["token"] as? NSString {
            UserModel.fetch(userId, withCompletion: { (result, error) in
                if error == .None {
                    var user: [String: AnyObject] = result.toDictionary()
                    user["deviceToken"] = deviceToken as String

                    let userModel = UserModel.init(dictionary: user)
                    userModel.update(withCompletion: { (result, error) in
                        print("New Token saved")
                    })
                }
            })
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.lounjeeToken = NSUserDefaults.standardUserDefaults().objectForKey("lounjeeToken") as? String
        self.userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
        
        // NSUserDefault not synchronised, need to be fixed
        if self.userId == 0 && self.lounjeeToken == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "UserDidChangeNotification", object: nil)
            self.performSegueWithIdentifier("onboarding", sender: self)
        }
        else {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            
            if let emailAddress = NSUserDefaults.standardUserDefaults().objectForKey("emailAddress") {
                Intercom.registerUserWithUserId("\(self.userId)", email: emailAddress as! String)
            }else{
                Intercom.registerUserWithUserId("\(self.userId)")
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDescriptionViewController.userDidAnswerToNotifications(_:)), name: "UserDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LounjeeTabBarController.dissmissViewController), name: StartDiscoveringViewController.validationNotificationName, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dissmissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
