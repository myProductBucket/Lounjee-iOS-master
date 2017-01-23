//
//  SignInLinkedInViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 08.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom
import SwiftyJSON

class SignInLinkedInViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    var user:UserModel?
    let linkedInKey = "77y86kylxaqcyw"
    let linkedInSecret = "wSXqmtbc6mnePWZU"
    let authorizationEndPoint = "https://www.linkedin.com/uas/oauth2/authorization" // /oauth/v2
    let accessTokenEndPoint = "https://www.linkedin.com/uas/oauth2/accessToken"
    let redirect_uri = "https://linkedin.lounjee.com/auth"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        // Do any additional setup after loading the view.
        self.startAuthorization()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! LounjeeNavigationController
        if let vc = navController.topViewController as? NewUserPreferencesViewController {
            vc.user = self.user!
        }
    }
    
    func startAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"
    
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL = self.redirect_uri.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        // Create a random string based on the time interval (it will be in the form linkedin12345679).
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        
        // Set preferred scope.
        let scope = "r_basicprofile%20r_emailaddress"
        
        var authorizationURL = "\(self.authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(self.linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        let request = NSURLRequest(URL: NSURL(string: authorizationURL)!)
        self.webView.loadRequest(request)
        
    }
    
    // MARK: WEB METHODS
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!
        
        if url.host == "linkedin.lounjee.com" {
            if url.absoluteString.rangeOfString("code") != nil {
                // Extract the authorization code.
                let urlParts = url.absoluteString.componentsSeparatedByString("?")
                let code = urlParts[1].componentsSeparatedByString("=")[1]

                self.requestForAccessToken(code)
            }
        }

        return true
    }
    
    
    // TODO: Handle Error
    func requestForAccessToken(authorizationCode: String) {
        let grantType = "authorization_code"
        let redirectURL = self.redirect_uri.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!

        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(self.linkedInKey)&"
        postParams += "client_secret=\(self.linkedInSecret)"
        
        let postData = postParams.dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: NSURL(string: self.accessTokenEndPoint)!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        // Initialize a NSURLSession object.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // Make the request.
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! NSHTTPURLResponse).statusCode
        
            switch statusCode{
            case 200:
                do {
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    let accessToken = dataDictionary["access_token"] as! String
                    
                    NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "linkedInAcessToken")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    linkedinAPI.getProfile(withCompletion: { (result, error) in
                        if let linkedinId = result.linkedinId {
                            self.user = result
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
                                        self.performSegueWithIdentifier("connected", sender: self)
                                    })
                                }
                                
                                // Save Email address in MailChimp
                                
                                self.sendEmailToMailChimp()

                            })
                        }
                    })
                    
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            default:
                print("Error not handeled")
            }
        }
        
        task.resume()
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
