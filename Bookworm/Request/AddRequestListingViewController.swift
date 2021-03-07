//
//  AddRequestListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 3/2/21.
//

import UIKit
import Firebase
import CoreLocation


class AddRequestListingViewController: UIViewController {
    
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookAuthorLabel: UITextField!
    @IBOutlet weak var bookPublishDateLabel: UITextField!
    @IBOutlet weak var bookEditionLabel: UITextField!
    @IBOutlet weak var bookISBNLabel: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addRequestButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var bookAuthors: [String] = []
    var bookTitle: String = ""
    var bookISBN: String = ""
    var bookCoverImageS: Data? = nil
    var bookCoverImageM: Data? = nil
    var bookCoverImageL: Data? = nil
    var bookPublishDate: String = ""
    var bookLocation: String = ""
    var bookCondition: String = ""
    
    var storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //format button + view
        addRequestButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
        
        fillInBookInfo()
    }
    
    func fillInBookInfo (){
        //fill in book cover if available
        if let coverImageDataM = bookCoverImageM, let coverImageM = UIImage(data: coverImageDataM) {
            self.bookCoverImage.image = coverImageM
        } else if let coverImageDataS = bookCoverImageS, let coverImageS = UIImage(data: coverImageDataS) {
            self.bookCoverImage.image = coverImageS
//        } else if let coverImageDataL = bookCoverImageL, let coverImageL = UIImage(data: coverImageDataL) {
//            self.bookCoverImage.image = coverImageL
        } else {
            self.bookCoverImage.image = UIImage(systemName: "book")
        }
        
        
        //fill in book title
        self.bookTitleLabel.text = bookTitle
        
        //fill in book publish date if available
        self.wait()
        OpenLibraryAPI.ISBN(bookISBN, completion: { response, error in
            if let unwrappedError = error {
                print("search error")
                print(unwrappedError)
                return
            }
            guard let unwrappedResponse = response else {
                print("no response")
                return
            }
            
            if let publishDate = unwrappedResponse["publish_date"] as? String {
                self.bookPublishDateLabel.text = "Publish Date: " + publishDate
            } else {
                self.bookPublishDateLabel.text = "Publish Date: None found"
            }
            self.start()
        })
        
        //fill in book author
        self.bookAuthorLabel.text = "Authors:" + bookAuthors.joined(separator: ", ")
        
        //fill in book isbn
        self.bookISBNLabel.text = "ISBN: " + bookISBN
    }
    
    func createNewListing(userID: String, uniqueBookID: String, date: String){
        // make push call to database
        self.ref.child("Books").child(uniqueBookID).setValue(["Title": self.bookTitle, "Author": self.bookAuthors.joined(separator: ", "), "Date_Published": self.bookPublishDate, "Edition": "", "ISBN": self.bookISBN, "Condition": self.bookCondition, "User": userID, "Date_Posted": date, "Location": self.bookLocation, "User_Description": "Buyer", "Photo_Cover": "\(uniqueBookID).jpg"])
    }
    
    func getCityFromPostalCode(postalCode: String, userID: String, uniqueBookID: String, date: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(postalCode) { results, error in
            // Placemark gives an array of best/closest results. First value of array most accurate.
            if let placemark = results?[0] {
                let locality = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                print(locality)
                print(state)
                self.bookLocation = "\(locality), \(state)"
                self.createNewListing(userID: userID, uniqueBookID: uniqueBookID, date: date )
            }
            if let error = error {
                print(error)
                self.bookLocation = "Did not Work"
            }
        }
    }
    

    @IBAction func didPressAddRequest(_ sender: Any) {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let date = formatter.string(from: currentDateTime)
        let uniqueBookID = UUID().uuidString


        // save image to Firebase storage with uniqueBookID.jpg as image path
        let imageRef = storageRef.child("\(uniqueBookID).jpg")

        // Conditional check, use default book image if no image found for book cover
        if let bookCoverData = bookCoverImageM {
            imageRef.putData(bookCoverData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error)
                }
                if let metadata = metadata {
                    print(metadata)
                }
            }
        } else if let bookCoverData = bookCoverImageS {
            imageRef.putData(bookCoverData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error)
                }
                if let metadata = metadata {
                    print(metadata)
                }
            }
        } else { //default book image
            if let bookImage = UIImage(systemName: "book"), let bookImageData = bookImage.jpegData(compressionQuality: 1.0) {
                imageRef.putData(bookImageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("error w default image")
                        print(error)
                    }
                    if let metadata = metadata {
                        print("error w default image")
                        print(metadata)
                    }
                }
            }
        }

        // Grab user ID from logged in user
        guard let userID = Auth.auth().currentUser?.uid else {
            assertionFailure("Couldn't unwrap userID")
            return
        }

        // Grab zipcode from user, change zipcode to city
        self.ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userData = snapshot.value as? [String: String]
            let bookZipCode = userData?["ZipCode"] ?? ""

            self.getCityFromPostalCode(postalCode: bookZipCode, userID: userID, uniqueBookID: uniqueBookID, date: date)
        })

        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTap(_ sender: Any) {
        tapGestureRecognizer.view?.endEditing(true)
    }
    
    //following two functions taken from hw solutions
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
