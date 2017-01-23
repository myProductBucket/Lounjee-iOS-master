//
//  OnBoardingViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 07.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom
import SwiftyJSON

class OnBoardingViewController: UIViewController {
    
    var user:UserModel?

    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let attributedString = NSMutableAttributedString(string: "SIGN-IN with LinkedIn")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "MyriadPro-BoldCond", size: 22.0)!, range: NSMakeRange(0, 7))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "MyriadPro-Cond", size: 19.0)!, range: NSMakeRange(8, 13))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7), range: NSMakeRange(0, 21))
        self.signInButton.setAttributedTitle(attributedString, forState: .Normal)
        self.signInButton.layer.cornerRadius = 3
        
        /*
         let attributedString = NSMutableAttributedString(string: "SIGN-IN with LinkedIn")
         attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "MyriadPro-BoldCond", size: 22.0)!, range: NSMakeRange(0, 7))
         attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "MyriadPro-Cond", size: 19.0)!, range: NSMakeRange(8, 13))
         attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7), range: NSMakeRange(0, 21))
         self.signInButton.setAttributedTitle(attributedString, forState: .Normal)
         self.signInButton.layer.cornerRadius = 3
 
        */
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInLinkedInTouchUp(sender: UIButton) {
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "linkedin:")!) {
            print("linkedin app installed")
            
            self.signInLinkedInNativeApp()
        }else{
            print("linkedin app not installed")
        
            let signInVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignInLinkedInViewController") as! SignInLinkedInViewController
            self.navigationController?.pushViewController(signInVC, animated: true)
        }

    }
    
    func signInLinkedInNativeApp() {
        let permissions = [LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION]
        LISDKSessionManager.createSessionWithAuth(permissions, state: nil, showGoToAppStoreDialog: true, successBlock: { (returnState) in
            print("LinkedIn session create success: \(returnState)")
            
            //            NSUserDefaults.standardUserDefaults().setObject(LISDKSessionManager.sharedInstance().session, forKey: "linkedInAcessToken")
            //            NSUserDefaults.standardUserDefaults().synchronize()
            
            LISDKAPIHelper.sharedInstance().getRequest("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,headline,location:(name,country:(code)),public-profile-url,picture-urls::(original),specialties,industry,num-connections,num-recommenders,positions)?format=json", success: { (response) in
                let data = response.data.dataUsingEncoding(NSUTF8StringEncoding)
                do {
                    var dicResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String:AnyObject]
                    // use anyObj here
                    if let linkedinId = dicResponse["id"] as? String {
                        dicResponse.removeValueForKey("id")
                        dicResponse["linkedinId"] = linkedinId
                        let userResult = UserModel(dictionary: dicResponse)
                        
                        self.user = userResult
                        gCurrentUser = self.user
                        
                        NSUserDefaults.standardUserDefaults().setObject(gCurrentUser.pictureUrl, forKey: "pictureURL")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        let PostLogin = APIRouter.Postlogin(linkedinId: linkedinId)
                        APIManager.sendRequest(PostLogin, withCompletion: { (result, error) in
                            
                            if let id = result["id"] as? Int, let token = result["token"] as? String {
                                NSUserDefaults.standardUserDefaults().setInteger(id, forKey: "userId")
                                NSUserDefaults.standardUserDefaults().setObject(token, forKey: "lounjeeToken")
                                NSUserDefaults.standardUserDefaults().setObject(result["emailAddress"], forKey: "emailAddress")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                
                                UserModel.fetch(id) { (result, error) in
                                    gCurrentUser = result
                                    
                                    let userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
                                    gCurrentUser.id = userId
                                    
                                    let string = NSUserDefaults.standardUserDefaults().objectForKey("pictureURL") as? String
                                    if string != nil{
                                        gCurrentUser.pictureUrl = NSUserDefaults.standardUserDefaults().objectForKey("pictureURL") as? String
                                    }
                                    
                                    var fullName: String = ""
                                    
                                    if let firstName = gCurrentUser.firstName {
                                        fullName = firstName + " "
                                    }
                                    if let lastName = gCurrentUser.lastName {
                                        fullName += lastName
                                    }
                                    
                                    Intercom.updateUserWithAttributes(["name": fullName])
                                    
                                }
                                
                                if let emailAddress = gCurrentUser.emailAddress {
                                    Intercom.registerUserWithUserId("\(id)", email: emailAddress)
                                }else {
                                    Intercom.registerUserWithUserId("\(id)")
                                }
                                
                                NSNotificationCenter.defaultCenter().postNotificationName(StartDiscoveringViewController.validationNotificationName, object: self)
                                
                                
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let navController = self.storyboard?.instantiateViewControllerWithIdentifier("LounjeeNavigationController") as! LounjeeNavigationController
                                    if let vc = navController.topViewController as? NewUserPreferencesViewController {
                                        vc.user = self.user!
                                    }
                                    self.presentViewController(navController, animated: true, completion: nil)
                                })
                            }
                            
                            // Save Email address in MailChimp
                            
                            self.sendEmailToMailChimp()
                        })
                    }
                    
                    print("\(dicResponse)")
                } catch {
                    print("json error: \(error)")
                }
                }, error: { (error) in
                    print("LISDKAPIError: \(error)")
            })
            
        }) { (error) in
            print("LinkedIn session create error: \(error.localizedDescription)")
        }
    }
    
    func sendEmailToMailChimp() {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(MailChimpAPIBaseURL)/\(MailChimpListID)/members")!)
        let session = NSURLSession.sharedSession()
        //{
//        "email_address": "urist.mcvankab@freddiesjokes.com",
//        "status": "subscribed",
//        "merge_fields": {
//            "FNAME": "Urist",
//            "LNAME": "McVankab"
//        }
//    }
        let mergeFields:NSDictionary = ["FNAME":(self.user?.firstName)!, "LNAME":(self.user?.lastName)!]
        let body:NSDictionary = ["email_address":(self.user?.emailAddress)!,
                    "status":"subscribed",
                    "merge_fields":mergeFields]

        do {
            let jsonBody = try NSJSONSerialization.dataWithJSONObject(body, options: [])
            request.HTTPBody = jsonBody
            request.HTTPMethod = "POST"
            
            let userNamePassword = "\((self.user?.firstName)! + " " + (self.user?.lastName)!):\(MailChimpAPIKey)"
            
            request.setValue("Basic \(self.encodeStringTo64(userNamePassword))", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let jsonData = data {
                    let json:JSON = JSON(data: jsonData)
                    print("\(json)")
                }else {
                    
                }
            })
            task.resume()
        }catch {
            
        }
        
    }
    
    func encodeStringTo64(str: String) -> String {
        let utf8str = str.dataUsingEncoding(NSUTF8StringEncoding)
        
        if let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        {
            
            print("Encoded:  \(base64Encoded)")
            return base64Encoded
        }
        return ""
    }
}
