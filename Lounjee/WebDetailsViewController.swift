//
//  WebDetailsViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 05.04.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class WebDetailsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    
    var request:NSURLRequest?
    var isModal:Bool = false

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.rightBarButtonItem = nil
        
        if isModal {
            self.navigationItem.rightBarButtonItem = self.closeBtn
        }

        if self.request != nil {
            self.webView.loadRequest(self.request!)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtn(sender: AnyObject) {
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
