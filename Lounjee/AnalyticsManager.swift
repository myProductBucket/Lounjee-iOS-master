//
//  AnalyticsManager.swift
//  Lounjee
//
//  Created by Arnaud AUBRY on 24/04/2016.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import Mixpanel

class AnalyticsManager: NSObject {
    static let MixpanelToken = "6fd9386a0e39e3f93ff901abad4a8008"
    
    static func initAnalyticsWithLaunchOptions(options: [NSObject: AnyObject]?) {
        Mixpanel.sharedInstanceWithToken(AnalyticsManager.MixpanelToken, launchOptions: options)
    }
 
    static func identify(uid: String) {
        Mixpanel.sharedInstance().identify(uid)
    }
    
    static func people(userInfos: [String: AnyObject]) {
        Mixpanel.sharedInstance().people.set(userInfos)
    }
    
    static func track(event: String, properties: [String: AnyObject]?) {
        Mixpanel.sharedInstance().track(event, properties: properties)
    }
}
