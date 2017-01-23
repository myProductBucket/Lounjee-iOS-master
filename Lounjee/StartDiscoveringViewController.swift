//
//  StartDiscoveringViewController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 10.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class StartDiscoveringViewController: UIViewController {
    
    @IBOutlet weak var startDiscoveringBtn: UIButton!
    
    static let validationNotificationName = "StartDiscoveringViewControllerDidValidate"
    var userData:[String:AnyObject]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startDiscovering(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(StartDiscoveringViewController.validationNotificationName, object: self)
    }
    

    
}
