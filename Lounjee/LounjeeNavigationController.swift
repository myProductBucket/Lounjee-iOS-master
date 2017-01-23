//
//  LounjeeNavigationController.swift
//  Lounjee
//
//  Created by Junior Boaventura on 09.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class LounjeeNavigationController: UINavigationController {
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indexOfViewController(vc: UIViewController) -> Int {
        var index = 0
    
        for viewController in self.viewControllers {
            if vc == viewController {
                return index
            }
            index += 1
        }
        return index
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
