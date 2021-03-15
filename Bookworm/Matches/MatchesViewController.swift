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
    @IBOutlet weak var buyerSellerColorView: UIView!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    var storageRef = Storage.storage().reference()
    
    func fillInBookCell (book: BookCell){
        
        let image = UIImage(data: book.bookCoverData as Data)
        self.bookCoverImage.image = image
        
        self.bookTitleLabel.text = book.title
        self.locationLabel.text = book.location
        
        //display condition label if user is selling
        if book.userDescription == "Buyer"{
            self.conditionLabel.text = ""
            self.buyerSellerColorView.backgroundColor = .systemOrange
        } else{
            self.conditionLabel.text = "Condition: \(book.condition)"
            self.buyerSellerColorView.backgroundColor = .systemBlue
        }
        
    }

}

class MatchesViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var matchesTableView: UITableView!
    let locationManager = CLLocationManager()
    var books: [BookCell] = []
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //format buttons
        filterButton.layer.cornerRadius = 5
        
        self.navigationController?.isNavigationBarHidden = true

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        matchesTableView.dataSource = self
        matchesTableView.delegate = self
        matchesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // For getting database data and reloadData for listingsTableView
        self.books.removeAll()
        self.makeDatabaseCallsforReload()//filterOption: filterValue)
    }

    func makeDatabaseCallsforReload() {
        let storageRef = Storage.storage().reference()
        
        self.ref.child("Posts").queryOrdered(byChild: "Date_Posted").observe(.childAdded, with: { (snapshot) in
            let results = snapshot.value as? [String : String]
            let user = results?["User"] ?? ""
            let condition = results?["Condition"] ?? ""
            let isbn = results?["ISBN"] ?? ""
            let edition = results?["Edition"] ?? ""
            let author = results?["Author"] ?? ""
            let datePublished = results?["Date_Published"] ?? ""
            let datePosted = results?["Date_Posted"] ?? ""
            let timeStamp = results?["Time_Stamp"] ?? ""
            let location = results?["Location"] ?? ""
            let title = results?["Title"] ?? ""
            let userDescription = results?["User_Description"] ?? ""
            
            // Phooto_Cover from DB returns path in FBStorage
            let bookCover = results?["Photo_Cover"] ?? ""
            
            // get book image reference from Firebase Storage
            let bookCoverRef = storageRef.child(bookCover)
            
            // download URL of reference, then get contents of URL and set imageView to UIImage
            bookCoverRef.downloadURL { url, error in
                guard let imageURL = url, error == nil else {
                    print(error ?? "")
                    return
                }
                
                guard let bookCoverData = NSData(contentsOf: imageURL) else {
                    assertionFailure("Error in getting Data")
                    return
                }
                
                self.ref.child("Users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                    let userData = snapshot.value as? [String: String]
                    
                    let firstName = userData?["FirstName"] ?? ""
                    let lastName = userData?["LastName"] ?? ""
                    
                    let userName = firstName + " " + lastName
                    
                    let databaseData = BookCell(title: title, isbn: isbn, edition: edition, publishDate: datePublished, author: author, condition: condition, location: location, buyerSellerID: user, buyerSeller: userName, postDate: datePosted, timeStamp: timeStamp, bookCover: bookCover, userDescription: userDescription, bookCoverData: bookCoverData)
                    
                    DispatchQueue.main.async {
                        
                        guard let userID = Auth.auth().currentUser?.uid else {
                            assertionFailure("Couldn't unwrap userID")
                            return
                        }
                        
                        var wishListISBNs: [String] = []
                        var inventoryISBNs:  [String] = []
                        
//                        self.ref.child("Wishlists/\(userID)").observe(.childAdded, with: { (snapshot) in
//                            let results = snapshot.value as? [String : String]
//                            let isbn = results?["ISBN"] ?? ""
//                            wishListISBNs.append(isbn)
//                            print(wishListISBNs)
//                        })
//
//
//                        self.ref.child("Inventories/\(userID)").observe(.childAdded, with: { (snapshot) in
//                            let results = snapshot.value as? [String : String]
//                            let isbn = results?["ISBN"] ?? ""
//                            inventoryISBNs.append(isbn)
//                            print(inventoryISBNs)
//                        })
//
//                        print("wishListISBNs")
//                        print(wishListISBNs)
//                        print("inventoryISBNs")
//                        print(inventoryISBNs)
                        
                        //hardcoded for now
                        wishListISBNs.append("9781472263667")
                        wishListISBNs.append("9780984782857")
                        inventoryISBNs.append("9780141182704")
                        
                        self.books.append(databaseData)
                        // Sort by date and time.
                        self.books.sort(by: {$0.timeStamp > $1.timeStamp})
                        self.books = self.books.filter { (wishListISBNs.contains($0.isbn) && $0.userDescription == "Seller") || (inventoryISBNs.contains($0.isbn) && $0.userDescription == "Buyer")}
                        self.matchesTableView.reloadData()
                    }
                    
                })
            }
            
        })
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("latitude: \(location.latitude) longitude: \(location.longitude)")
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
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: "matchesCell") as? MatchesTableViewCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        let book = books[indexPath.row]
        cell.fillInBookCell(book: book)
//        cell.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = books[indexPath.row]
        // empty dblistingVC for now
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "matchesEntryVC")
        guard let matchesEntryVC = vc as? MatchesEntryViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        //pass data over to matchesentryvc
        present(matchesEntryVC, animated: true, completion: nil)
    }
}
