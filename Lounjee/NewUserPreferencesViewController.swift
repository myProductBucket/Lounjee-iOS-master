//
//  NewUserPreferencesViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 09.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Intercom

class NewUserPreferencesViewController: UIViewController {
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var indexNav:Int?
    var userConfig = [String:AnyObject]()
    var instructionString = "It improves the quality of the matches"

    var userDelegate: UserProfileDelegate?
    
    var industries:[[String:AnyObject]]?
    var purposes:[[String:AnyObject]]?
    
    var count:Int = 0
    var edit:Bool = false
    var tag:Int = 0

    var user: UserModel!
    var userIndustriesCodes = [Int]()
    var userPurposesCodes = [Int]()
    
    let red:UIColor = UIColor(red: 185/255.0, green: 60/255.0, blue: 57/255.0, alpha: 1.0)
    let blue: UIColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
    let turquoise: UIColor = UIColor(red: 32/255.0, green: 55/255.0, blue: 86/255.0, alpha: 1.0)

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.hidden = true
        self.activityIndicator.startAnimating()
        
        if self.edit {
            self.btn.setTitle("SAVE", forState: UIControlState.Normal)
            
            if self.tag == 2 || self.tag == 3 {
                self.loadPurposes()
            }

            if self.tag == 1 {
                self.loadIndustries()
            }
        }
        else if let navController = self.navigationController as? LounjeeNavigationController {
            self.closeBtn?.enabled = false
            self.navigationItem.rightBarButtonItem = nil
            self.indexNav = navController.indexOfViewController(self)
   
            if self.indexNav == 0 {
                self.loadPurposes()
            }
            
            if self.indexNav == 1 {
                self.tableView?.hidden = false
                self.activityIndicator.stopAnimating()
            }
            
            if self.indexNav == 2  {
                self.loadIndustries()
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
        self.descriptionLabel?.text = self.instructionString
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPurposes() {
        let purposes = APIRouter.getPurposes
        APIManager.sendRequest(purposes) { (result, error) in
            if let data = result["purposes"] as? [[String:AnyObject]] {
                self.purposes = data
                
                if self.tag == 2, let userLookings = self.user.lookings {
                    let codes = self.selectData(userLookings, list: data, key: "looking")
                    self.userPurposesCodes.appendContentsOf(codes)
                } else if self.tag == 3, let userOffers = self.user.offers {
                    let codes = self.selectData(userOffers, list: data, key: "offer")
                    self.userPurposesCodes.appendContentsOf(codes)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.hidden = false
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    
    func selectData(userList: [[String:AnyObject]], list: [[String:AnyObject]], key: String) -> [Int] {
        var codesList = [Int]()
        
        userList.forEach({
            if let description = $0["label"] as? String {
                list.forEach({
                    if description == $0[key] as? String, let code = $0["code"] as? Int {
                        self.count += 1
                        codesList.append(code)
                    }
                })
            }
        })
        print(codesList)
        return codesList
    }
    
    func loadIndustries() {
        let industries = APIRouter.getIndustries
        APIManager.sendRequest(industries) { (result, error) in
            if let data = result["industries"] as? [[String:AnyObject]] {
                
                self.industries = data

                if self.edit == false, let industry = self.user.industry {
                    let codes = self.selectData([["description": industry]], list: data, key: "description")
                    self.userIndustriesCodes.appendContentsOf(codes)
                } else if let userIndustries = self.user.industries {
                    let codes = self.selectData(userIndustries, list: data, key: "description")
                    self.userIndustriesCodes.appendContentsOf(codes)
                }

                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.hidden = false
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    
    func selectCellStyle(cell: UITableViewCell, color: UIColor) -> UITableViewCell {
        cell.textLabel?.font = UIFont(name: "MyriadPro-Bold", size: 16.0)
        cell.textLabel?.textColor = color
        return cell
    }
    
    
    func getDataFromTableView(data: [[String: AnyObject]], tableView: UITableView) -> [Int] {
        var dataSelected = [Int]()

    
//        dataSelected.appendContentsOf(self.userIndustriesCodes)
        

        if let indexPaths = tableView.indexPathsForSelectedRows {

            for indexPath in indexPaths {
                if let code = data[indexPath.row]["code"] as? Int {
                    dataSelected.append(code)
                }
            }
        }
        return dataSelected
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserDescriptionViewController {
            vc.userConfig = self.userConfig
            vc.user = self.user
            
            if let codes = self.industries {
                vc.userConfig["industries"] = self.getDataFromTableView(codes, tableView: self.tableView)
            }
            
        }
    }
    
    func logEventsForNumberOfProfileEdits() {
        Intercom.logEventWithName(NumberOfProfileEdit)
    }

    @IBAction func closeBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pressedNext(sender: AnyObject) {
        
        
        // Mark : EDIT
        if self.edit, let delegate = self.userDelegate{
            let userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
            if self.tag == 3, let codes = self.purposes {
                let selectedCodes = self.getDataFromTableView(codes, tableView: self.tableView)
                if selectedCodes.count > 0 {
                    let postOffers = APIRouter.PostOffers(id: userId, data: selectedCodes)
                    APIManager.sendRequest(postOffers, withCompletion: { (result, error) in
                        delegate.updateUser()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    // Log events for the number of the profile edits in Intercom
                    self.logEventsForNumberOfProfileEdits()
                }
            
            }
            
            if self.tag == 2, let codes = self.purposes {
                let selectedCodes = self.getDataFromTableView(codes, tableView: self.tableView)
                if selectedCodes.count > 0 {
                    let postLookings = APIRouter.PostLookings(id: userId, data: selectedCodes)
                    APIManager.sendRequest(postLookings, withCompletion: { (result, error) in
                        delegate.updateUser()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    // Log events for the number of the profile edits in Intercom
                    self.logEventsForNumberOfProfileEdits()
                }
            }
            
            if self.tag == 1, let codes = self.industries {
                let selectedCodes = self.getDataFromTableView(codes, tableView: self.tableView)
                if selectedCodes.count > 0 {
                    let postIndustries = APIRouter.PostIndustries(id: userId, data: selectedCodes)
                    APIManager.sendRequest(postIndustries, withCompletion: { (result, error) in
                        delegate.updateUser()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    // Log events for the number of the profile edits in Intercom
                    self.logEventsForNumberOfProfileEdits()
                }
            }
            return
        }
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("NewUserPreferencesViewController") as! NewUserPreferencesViewController
        if let navController = self.navigationController as? LounjeeNavigationController {
            let index = navController.indexOfViewController(self)

            if index == 0 {
                viewController.navigationTitle.title = "What can you Offer?"
                if let codes = self.purposes {
                    viewController.userConfig["lookings"] = self.getDataFromTableView(codes, tableView: self.tableView)
                    viewController.purposes = self.purposes
                    viewController.user = self.user
                }
                
            }else if index == 1 {
                viewController.navigationTitle.title = "Select your industries"
                viewController.instructionString = "Max 5 elements"
                
                viewController.industries = self.industries
                viewController.userConfig = self.userConfig
                viewController.user = self.user
                
                if let codes = self.purposes {
                    viewController.userConfig["offers"] = self.getDataFromTableView(codes, tableView: self.tableView)
                }
                
            }else if index == 2 {
                performSegueWithIdentifier("signInStep1", sender: self)
                return
            }
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension NewUserPreferencesViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if industries != nil {
            if self.count < 5 {
                self.count += 1
            } else {
                return
            }
        }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false {
                cell.accessoryType = .Checkmark
                cell.textLabel?.font = UIFont(name: "MyriadPro-Bold", size: 16.0)
                
                switch self.tag {
                case 1:
                    cell.textLabel?.textColor = self.red
                case 2:
                    cell.textLabel?.textColor = self.blue
                case 3:
                    cell.textLabel?.textColor = self.turquoise
                default:
                    cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
                }
                
                if let index = self.indexNav {
                    switch index {
                    case 0:
                        cell.textLabel?.textColor = self.turquoise
                    case 1:
                        cell.textLabel?.textColor = self.blue
                    case 2:
                        cell.textLabel?.textColor = self.red
                    default:
                        cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
                    }
                }

            }
            else {
                cell.accessoryType = .None
                cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
                cell.textLabel?.font = UIFont(name: "MyriadPro-Regular", size: 16.0)
            }

            cell.accessoryType = .Checkmark
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let code = self.industries?[indexPath.row]["code"] as? Int, let index = self.userIndustriesCodes.indexOf(code) {
            self.userIndustriesCodes.removeAtIndex(index)
        }

        if let code = self.purposes?[indexPath.row]["code"] as? Int, let index = self.userPurposesCodes.indexOf(code) {
            self.userPurposesCodes.removeAtIndex(index)
        }
        
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .None
            cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
            cell.textLabel?.font = UIFont(name: "MyriadPro-Regular", size: 16.0)
            self.count -= 1
        }
    }
}

extension NewUserPreferencesViewController: UITableViewDataSource{

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let index = self.indexNav {
            if index == 0 || index == 1, let array = self.purposes {
                return array.count
            }
            
            if index == 2, let array = self.industries {
                return array.count
            }
        }
        
        if self.tag == 2 || self.tag == 3 {
            if let array = self.purposes {
                return array.count
            }
        }
        
        if self.tag == 1 {
            if let array = self.industries {
                return array.count
            }
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        if tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false {
            cell.accessoryType = .Checkmark
            cell.textLabel?.font = UIFont(name: "MyriadPro-Bold", size: 16.0)

            switch self.tag {
            case 1:
                cell.textLabel?.textColor = self.red
            case 2:
                cell.textLabel?.textColor = self.blue
            case 3:
                cell.textLabel?.textColor = self.turquoise
            default:
                cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
            }
            
            if let index = self.indexNav {
                switch index {
                case 0:
                    cell.textLabel?.textColor = self.turquoise
                case 1:
                    cell.textLabel?.textColor = self.blue
                case 2:
                    cell.textLabel?.textColor = self.red
                default:
                    cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
                }
            }
        }
        else {
            cell.accessoryType = .None
            cell.textLabel?.textColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1.0)
            cell.textLabel?.font = UIFont(name: "MyriadPro-Regular", size: 16.0)
        }
        
        switch tag {
        case 1:
            if let purpose = self.industries?[indexPath.row] {
                let text = purpose["description"] as? String
                cell.textLabel?.text = text
                
                if let userIndutries = self.user.industries {
                    userIndutries.forEach({
                        if let industry = $0["description"] as? String where industry == text {
                            cell.accessoryType = .Checkmark
                            cell = self.selectCellStyle(cell, color: self.red)
                            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                        }
                    })
                }
            }

        case 2:
            if let purpose = self.purposes?[indexPath.row] {
                let text = purpose["code"] as? Int
                cell.textLabel?.text = purpose["looking"] as? String
                
                self.userPurposesCodes.forEach({
                    if $0 == text {
                        cell.accessoryType = .Checkmark
                        cell = self.selectCellStyle(cell, color: self.blue)
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                })
            }

        case 3:
            if let purpose = self.purposes?[indexPath.row] {
                let text = purpose["code"] as? Int
                cell.textLabel?.text = purpose["offer"] as? String
                
                self.userPurposesCodes.forEach({
                    if $0 == text {
                        cell.accessoryType = .Checkmark
                        cell = self.selectCellStyle(cell, color: self.turquoise)
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                })
            }
        default:
            print("")
        }
        
        if let index = self.indexNav {
            switch index {
            case 0:
                if let purpose = self.purposes?[indexPath.row] {
                    let text = purpose["looking"] as? String
                    cell.textLabel?.text = text
                }
            case 1:
                if let purpose = self.purposes?[indexPath.row] {
                    let text = purpose["offer"] as? String
                    cell.textLabel?.text = text
                }
            case 2:
                if let purpose = self.industries?[indexPath.row] {
                    let text = purpose["description"] as? String
                    cell.textLabel?.text = text

                    if self.user.industry == text {
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                        cell = self.selectCellStyle(cell, color: self.red)
                        cell.accessoryType = .Checkmark
                    }
                }
            default:
                print("")
            }
        }
        
        cell.tintColor = UIColor.init(red: 32/255, green: 55/255, blue: 86/255, alpha: 1)
        return cell
    }
}


