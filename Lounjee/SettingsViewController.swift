//
//  SettingsViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 01.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import MessageUI
import Intercom

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: ProfilePicture!
    @IBOutlet weak var tableView: UITableView!
    var userId: Int!
    @IBOutlet weak var userBanner: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        self.userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
        
        UserModel.fetch(self.userId) { (result, error) in
            if let pictureUrl = result.pictureUrl {
                dispatch_async(dispatch_get_main_queue(), {
                    if gCurrentUser.pictureUrl?.compare("") != NSComparisonResult.OrderedSame{
                        self.profilePicture.sd_setImageWithURL(NSURL(string: gCurrentUser.pictureUrl!), placeholderImage: UIImage(named: "default-profile"))
                        self.userBanner.sd_setImageWithURL(NSURL(string: gCurrentUser.pictureUrl!), placeholderImage: UIImage(named: "default-profile"))
                    }
                })
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicture.layer.cornerRadius = CGRectGetWidth(self.profilePicture.frame)/self.profilePicture.borderRadius
        self.profilePicture.layer.borderColor = self.profilePicture.borderColor.CGColor
        self.profilePicture.layer.borderWidth = self.profilePicture.borderWidth

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let vc = segue.destinationViewController as? AboutViewController {
            vc.hidesBottomBarWhenPushed = true
        }
        
        if let vc = segue.destinationViewController as? UserProfileViewController {
            vc.userData = gCurrentUser
            
            //vc.distanceLabel.alpha = 0.0
            //vc.iconLocation.alpha = 0.0
            //vc.startButton.alpha = 0.0
            
            vc.editable = true
            
        }
        
    }
}

extension SettingsViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        // Deconnect the user
        if row == 0 {
            self.performSegueWithIdentifier("aboutLounjee", sender: nil)
        }
        else if row == 1 {
            let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] ?? ""
            let mailComposer = MFMailComposeViewController()

            mailComposer.setToRecipients(["info@lounjee.com"])
            mailComposer.setSubject("Feedback on Lounjee v\(bundleVersion!)")
            mailComposer.mailComposeDelegate = self
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else if row == 2 {
            UserModel.logout()
            Intercom.reset()

            if let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LounjeeTabBarController") as? LounjeeTabBarController {
                self.navigationController?.presentViewController(vc, animated: true, completion: nil)
            }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row

        if  row == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.imageView?.image = UIImage(named: "icon-about-lounjee")
            return cell
        }
        else if row == 1 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel?.text = "Give us a feedback"
            cell.imageView?.image = UIImage(named: "icon-feedback")
            return cell
        }
        else if row == 2 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("logOut", forIndexPath: indexPath)
            cell.imageView?.image = UIImage(named: "icon-logout")
            return cell
        }
        
       
        return UITableViewCell()
    }
}
