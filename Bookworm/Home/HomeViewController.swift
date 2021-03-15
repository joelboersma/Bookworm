//
//  HomeViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 3/1/21.
//

import UIKit
import Firebase
import MessageUI
import CoreLocation
import MapKit

class ListingsTableViewCell: UITableViewCell {
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var buyerSellerLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var buyerSellerColorView: UIView!
    
    var storageRef = Storage.storage().reference()
    
    func fillInBookCell (book: BookCell, distance: String){
        
        let image = UIImage(data: book.bookCoverData as Data)
        self.bookCoverImage.image = image
        
        self.bookTitleLabel.text = book.title
        self.locationLabel.text = book.location
        self.distanceLabel.text = distance
        self.buyerSellerLabel.text = "\(book.userDescription): \(book.buyerSeller)"
        self.postDateLabel.text = "Posted: " + book.postDate
        
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

class HomeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FilterViewControllerDelegate, MFMessageComposeViewControllerDelegate, ReloadDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var listingsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var books: [BookCell] = []
    var distances: [String] = []
    let locationManager = CLLocationManager()
    var locationUpdateTimer = Timer()
    var currLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
    var ref = Database.database().reference()
    
    // 0 = Listing
    // 1 = Requests
    // Default: 2 = Both
    var filterValue = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        self.searchBar.delegate = self
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        
        
        self.activityIndicator.stopAnimating()
        filterButton.layer.cornerRadius = 5
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestLocation()
        }
        
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.locationUpdate), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // For getting database data and reloadData for listingsTableView
        self.books.removeAll()
        self.distances.removeAll()
        self.makeDatabaseCallsforReload(filterOption: filterValue)
    }
    
    
    func makeDatabaseCallsforReload(filterOption: Int) {
        let storageRef = Storage.storage().reference()
        
        self.wait()
        
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
                        
                        self.books.append(databaseData)
                        
                        // For listings
                        if (filterOption == 0){
                            self.books = self.books.filter { $0.userDescription != "Buyer" }
                        }
                        
                        // For requests
                        if (filterOption == 1) {
                            self.books = self.books.filter { $0.userDescription != "Seller" }
                        }
                        
                        // Default is both
                        // Sort by date and time.
                        self.books.sort(by: {$0.timeStamp > $1.timeStamp})
                        self.books.forEach({_ in self.distances.append("")})
                        for (index, book) in self.books.enumerated() {
                            self.getDistance(book.location) { (distance) in
                                self.distances[index] = distance
                                self.listingsTableView.reloadData()
                            }
                        }
                        self.listingsTableView.reloadData()
                        self.start()
                    }
                    
                })
            }
            
        })
        
    }
    
    func reload(index: Int) {
        books.remove(at: index)
        distances.remove(at: index)
        self.listingsTableView.reloadData()
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "filterVC")
        guard let filterVC = vc as? FilterViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        filterVC.selectedFilterValue = filterValue
        filterVC.delegate = self
        
        present(filterVC, animated: true, completion: nil)
    }
        
    func filterVCDismissed(selectedFilterValue: Int) {
        filterValue = selectedFilterValue
        self.books.removeAll()
        self.distances.removeAll()
        self.makeDatabaseCallsforReload(filterOption: selectedFilterValue)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
        // do Things For Searching
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: "listingsCell") as? ListingsTableViewCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        let book = books[indexPath.row]
        let distance = distances[indexPath.row]
        cell.fillInBookCell(book: book, distance: distance)
//        cell.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let book = books[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "dblistingVC")
        guard let dblistingVC = vc as? DatabaseListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        dblistingVC.bookTitle = book.title
        dblistingVC.userDescription = book.userDescription
        dblistingVC.buyerSellerID = book.buyerSellerID
        dblistingVC.buyerSeller = book.buyerSeller
        dblistingVC.bookAuthor = book.author
        dblistingVC.bookEdition = book.edition
        dblistingVC.bookISBN = book.isbn
        dblistingVC.bookPublishDate = book.publishDate
        dblistingVC.bookCoverImage = book.bookCover
        dblistingVC.bookIndex = indexPath.row
        dblistingVC.delegate = self
        
        present(dblistingVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let book = books[indexPath.row]
        let contact = UIContextualAction(style: .normal, title: "Contact") { (action, view, completion) in
            self.contactHandler(book)
            self.listingsTableView.setEditing(false, animated: true)
        }
        contact.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [contact])
    }
    
    func contactHandler(_ book: BookCell) {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        
        if(book.userDescription == "Buyer"){
            controller.body = "Hello " + book.buyerSeller + ", I saw your request for " + book.title + " on Book Worm and I have a copy! Are you interested?"
        }else{
            controller.body = "Hello " + book.buyerSeller + ", I am interested in your listing for " + book.title + " on Book Worm."
        }

        self.ref.child("Users/\(book.buyerSellerID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let buyerSellerData = snapshot.value as? [String: String]
            let buyerSellerContact = buyerSellerData?["PhoneNumber"] ?? ""
            controller.recipients = [buyerSellerContact]
            if MFMessageComposeViewController.canSendText() {
                self.present(controller, animated: true, completion: nil)
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDistance(_ location: String, completion: @escaping(String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if error != nil {
                print("Geocoder Address String failed with error")
                return
            }
            if let placemark = placemarks?.first {
                guard let cellLocation: CLLocationCoordinate2D = placemark.location?.coordinate else { return }
                let request = MKDirections.Request()

                // source and destination are the relevant MKMapItems
                let source = MKPlacemark(coordinate: self.currLocation)
                let destination = MKPlacemark(coordinate: cellLocation)
                request.source = MKMapItem(placemark: source)
                request.destination = MKMapItem(placemark: destination)

                // Specify the transportation type
                request.transportType = MKDirectionsTransportType.automobile;

                // If open to getting more than one route,
                // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
                request.requestsAlternateRoutes = true

                let directions = MKDirections(request: request)

                directions.calculate { (response, error) in
                    if let response = response, let route = response.routes.first {
                        completion(MKDistanceFormatter().string(fromDistance: route.distance))
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.currLocation = location
//        self.books.removeAll()
//        self.distances.removeAll()
//        self.makeDatabaseCallsforReload(filterOption: filterValue)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    @objc func locationUpdate() {
        self.locationManager.requestLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationUpdateTimer.invalidate()
    }
    
    func wait() {
        self.activityIndicator.startAnimating()
        self.view.alpha = 0.2
        self.view.isUserInteractionEnabled = false
    }
    
    func start() {
        self.activityIndicator.stopAnimating()
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
    }
}
