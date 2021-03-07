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
    
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var matchesTableView: UITableView!
    var changeTableID = 1
    let locationManager = CLLocationManager()
    var placeholderCurrentTitles: [String] = []
    var placeholderHistoryTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //format buttons
        historyButton.layer.cornerRadius = 5
        filterButton.layer.cornerRadius = 5
        
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
        
        placeholderCurrentTitles.append("ECS 171 Textbook")
        placeholderCurrentTitles.append("ECS 150 Textbook")
        placeholderCurrentTitles.append("FMS 001 Textbook")
        
        placeholderHistoryTitles.append("ECS 251 Textbook")
        placeholderHistoryTitles.append("EEC 270 Textbook")
        placeholderHistoryTitles.append("EEC 7 Textbook")
        
        matchesTableView.dataSource = self
        matchesTableView.delegate = self
        matchesTableView.reloadData()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("latitude: \(location.latitude) longitude: \(location.longitude)")
    }
    
    @IBAction func changeTableButtonPressed(_ sender: UIButton) {
        switch changeTableID {
        case 0:
            sender.setTitle("History", for: .normal)
            titleLabel.text = "Current"
            changeTableID += 1
        case 1:
            sender.setTitle("Current", for: .normal)
            titleLabel.text = "History"
            changeTableID -= 1
        default:
            print("Can't change button title")
        }
        matchesTableView.reloadData()
    }
    
    @IBAction func filterButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "filterVC")
        guard let filterVC = vc as? FilterViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        filterVC.categorySegment0 = "Inventory"
        filterVC.categorySegment1 = "Wishlist"
        present(filterVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch changeTableID {
        case 0:
            return placeholderHistoryTitles.count
        case 1:
            return placeholderCurrentTitles.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchesCell", for: indexPath) as? MatchesTableViewCell
        
        assert(indexPath.section == 0)
        
        switch changeTableID {
        case 0:
            cell?.bookTitleLabel.text = placeholderHistoryTitles[indexPath.row]
        case 1:
            cell?.bookTitleLabel.text = placeholderCurrentTitles[indexPath.row]
        default:
            print("Can't load table data")
        }
        
        return cell ?? UITableViewCell(style: .default, reuseIdentifier: "matchesCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        // empty dblistingVC for now
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "matchesEntryVC")
        guard let matchesEntryVC = vc as? MatchesEntryViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        switch changeTableID {
        case 0:
            matchesEntryVC.isCurrentTable = false
        case 1:
            matchesEntryVC.isCurrentTable = true
        default:
            print("Can't load table entry")
        }
        
        present(matchesEntryVC, animated: true, completion: nil)
    }
}
