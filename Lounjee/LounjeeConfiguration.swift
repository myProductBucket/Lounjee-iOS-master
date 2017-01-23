//
//  LounjeeConfiguration.swift
//  Lounjee
//
//  Created by Junior Boaventura on 09.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation
import UIKit

struct Env {
    
    // User interface settings
    struct UI {
        static let MainColor = UIColor(red: 17/255.0, green: 17/255.0, blue: 17/255.0, alpha: 1.0)
        static let SecondaryColor = UIColor.whiteColor()
    }
    
    struct Init {
        static func initializeAppearances() {
            UINavigationBar.appearance().barTintColor = Env.UI.MainColor
            UINavigationBar.appearance().tintColor = Env.UI.SecondaryColor
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "MyriadPro-Cond", size: 22.0)!]

            UITabBar.appearance().barTintColor = UIColor.blackColor()
            UITabBar.appearance().tintColor = Env.UI.SecondaryColor
        }
    }
}