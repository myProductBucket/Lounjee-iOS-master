//
//  LocationManager.swift
//  Pods
//
//  Created by Junior Boaventura on 29.03.16.
//
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    static let sharedInstance = LocationManager()
    
    private let _locationManager: CLLocationManager
    private var _didReceiveLocation: ((location: CLLocation?) -> Void)!

    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    var location: CLLocation? {
        return self._locationManager.location
    }
    
    override init() {
        self._locationManager = CLLocationManager()
        super.init()
        self._locationManager.delegate = self
    }
    
    func getUserLocation(completion: ((location: CLLocation?) -> Void)) {
        if let location = self._locationManager.location {
            completion(location: location)
            return
        }
        
        self._didReceiveLocation = completion
        self.startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            self._locationManager.startUpdatingLocation()
        }
        else {
            self._locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopUpdatingLocation() {
        self._locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self._locationManager.startUpdatingLocation()
        }
        else if let completion = self._didReceiveLocation {
            completion(location: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self._didReceiveLocation?(location: newLocation)
        self._didReceiveLocation = nil
        print("location updated...")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Locationmanager: \(error.localizedDescription)")
    }
}
