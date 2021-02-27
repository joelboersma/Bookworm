//
//  MatchedView.swift
//  Bookworm
//
//  Created by Mohammed Haque on 2/21/21.
//

import Foundation
import CoreLocation
import UIKit
import Firebase

class MatchesTableViewCell: UITableViewCell {
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
}

class MatchesViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var matchesTableView: UITableView!
    let locationManager = CLLocationManager()
    var placeholderTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground.
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        placeholderTitles.append("ECS 171 Textbook")
        placeholderTitles.append("ECS 150 Textbook")
        placeholderTitles.append("FMS 001 Textbook")
        matchesTableView.dataSource = self
        matchesTableView.delegate = self
        matchesTableView.reloadData()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("latitude: \(location.latitude) longitude: \(location.longitude)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchesCell", for: indexPath) as? MatchesTableViewCell
        
        assert(indexPath.section == 0)
        cell?.bookTitleLabel.text = placeholderTitles[indexPath.row]
        return cell ?? UITableViewCell(style: .default, reuseIdentifier: "matchesCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        // empty dblistingVC for now
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "matchesEntryVC")
        guard let matchedEntryVC = vc as? MatchesEntryViewController else {
            assertionFailure("couldn't find vc")
            return
        }

        present(matchedEntryVC, animated: true, completion: nil)
    }
}