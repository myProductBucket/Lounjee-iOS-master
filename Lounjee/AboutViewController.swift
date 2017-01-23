//
//  AboutViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 01.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    let about = [["title":"Terms and Conditions","url":"http://www.lounjee.com/termsandconditions"],["title":"Privacy Policy","url":"http://www.lounjee.com/privacypolicy"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "aboutLounjeeSegue" {
            let indexPath = sender as! NSIndexPath
            let vc = segue.destinationViewController as! WebDetailsViewController

            if let url = about[indexPath.row]["url"] {
                vc.request = NSURLRequest(URL: NSURL(string: url)!)
            }
        }
    }


}

extension AboutViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if (indexPath.row == 0) {
            self.performSegueWithIdentifier("tutoSegue", sender: nil)
        }
        else {
            self.performSegueWithIdentifier("aboutLounjeeSegue", sender: NSIndexPath(forRow: indexPath.row - 1, inSection: 0))
        }
    }
}

extension AboutViewController: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.about.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if (indexPath.row == 0) {
            cell.textLabel?.text = "How Lounjee works"
        }
        else {
            cell.textLabel?.text = self.about[indexPath.row - 1]["title"]
        }
        return cell
    }
}
