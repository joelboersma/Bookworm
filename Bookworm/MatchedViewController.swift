//
//  MatchedView.swift
//  Bookworm
//
//  Created by Mohammed Haque on 2/21/21.
//

import Foundation
import CoreLocation
import UIKit

class MatchedViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var tempLatitudeLabel: UILabel!
    @IBOutlet weak var tempLongitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground.
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        tempLatitudeLabel.text = "latitude: \(location.latitude)"
        tempLongitudeLabel.text = "longitude: \(location.longitude)"
    }
    
}
