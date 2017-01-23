//
//  LinkedinAPI.swift
//  Lounjee
//
//  Created by Junior Boaventura on 23.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation

struct linkedinAPI {
    
    static func getProfile(withCompletion completion: ((result: UserModel, error: APIError) -> Void)) {
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("linkedInAcessToken") {
            let targetURLString = "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,headline,location:(name,country:(code)),public-profile-url,picture-urls::(original),specialties,industry,num-connections,num-recommenders,positions)?format=json"
            
            let request = NSMutableURLRequest(URL: NSURL(string: targetURLString)!)
            request.HTTPMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if statusCode == 200 {
                    
                    do {
                        var dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                        let linkedinId = dataDictionary["id"] as! String
                        dataDictionary.removeValueForKey("id")
                        dataDictionary["linkedinId"] = linkedinId
                        let user = UserModel(dictionary: dataDictionary)
                        completion(result: user, error: .None)
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    static func getToken() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("linkedInAcessToken") as? String
    }
    
}