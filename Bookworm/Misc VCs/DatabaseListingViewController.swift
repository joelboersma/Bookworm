//
//  DatabaseListingViewController.swift
//  Bookworm
//
//  Created by Urvashi Mahto on 2/23/21.
//

import Foundation
import UIKit
import Firebase
import MessageUI
import CoreLocation



class DatabaseListingViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var bookPublishingDateLabel: UILabel!
    @IBOutlet weak var bookISBNLabel: UILabel!
    @IBOutlet weak var contactSellerButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    
    var storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
   
    var userDescription: String = ""
    var bookAuthor: String = ""
    var bookTitle: String = ""
    var buyerSellerID: String = ""
    var buyerSeller: String = ""
    var bookPublishDate: String = ""
    var bookEdition: String = ""
    var bookISBN: String = ""
    var bookCoverImage: String = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //format buttons + view
        contactSellerButton.layer.cornerRadius = 5
        addToWishlistButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
    
        addToWishlistButton.setTitle("Add to Wishlist", for: .normal)
        
        switch userDescription {
        case "Buyer":
            contactSellerButton.backgroundColor = .systemOrange
            contactSellerButton.setTitle("Contact Buyer", for: .normal)
        case "Seller":
            contactSellerButton.backgroundColor = .systemBlue
            contactSellerButton.setTitle("Contact Seller", for: .normal)
        default:
            print("invalid user description: " + userDescription)
        }
        
        fillInBookInfo()
        // Do any additional setup after loading the view.
    }
    
    
    func fillInBookInfo() {
        let bookCoverRef = storageRef.child(bookCoverImage)
        
        bookCoverRef.downloadURL { url, error in
            guard let imageURL = url, error == nil else {
                print(error ?? "")
                return
            }
            
            guard let data = NSData(contentsOf: imageURL) else {
                assertionFailure("Error in getting Data")
                return
            }
            
            let image = UIImage(data: data as Data)
            self.bookImageView.image = image
        }
        
        self.bookTitleLabel.text = bookTitle
        self.bookAuthorLabel.text = "Author: \(bookAuthor)"
        self.bookPublishingDateLabel.text = "Publish Date: \(bookPublishDate)"
        
        self.bookISBNLabel.text = "ISBN: \(bookISBN)"
        
    }
    
    @IBAction func addToWishlistClicked(_ sender: Any) {
        self.wait()
        let currentDateTime = Date()
        let timestamp = String(currentDateTime.timeIntervalSince1970)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let date = formatter.string(from: currentDateTime)
        let uniquePostID = UUID().uuidString

        // save image to Firebase storage with uniqueBookID.jpg as image path
        let imageRef = storageRef.child("\(uniquePostID).jpg")
        
        let bookCoverRef = storageRef.child(bookCoverImage)
        bookCoverRef.downloadURL { url, error in
            guard let imageURL = url, error == nil else {
                print(error ?? "")
                return
            }
            
            guard let bookCoverData = NSData(contentsOf: imageURL) as Data? else {
                assertionFailure("Error in getting Data")
                return
            }
            
            imageRef.putData(bookCoverData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error)
                }
                if let metadata = metadata {
                    print(metadata)
                }

                // Grab user ID from logged in user
                guard let userID = Auth.auth().currentUser?.uid else {
                    assertionFailure("Couldn't unwrap userID")
                    return
                }
                
                //add book isbn to user's wishlist
                self.ref.child("Wishlists").child(userID).child(uniquePostID).setValue(["ISBN": self.bookISBN])
                
                
                // Grab zipcode from user
                self.ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let userData = snapshot.value as? [String: String]
                    let bookZipCode = userData?["ZipCode"] ?? ""
                    let userFirstName = userData?["FirstName"] ?? ""
                    let userLastName = userData?["LastName"] ?? ""
                    let userFullName = userFirstName + " " + userLastName
                    
                    //add new post to "Posts" in database
                    // make push call to database
                    self.getCityFromPostalCode(postalCode: bookZipCode, userID: userID, uniquePostID: uniquePostID, date: date, timestamp: timestamp)
                
                    
                    // add user as a "Buyer" of this book under database's "Books"
                    self.ref.child("Books").child(self.bookISBN).observeSingleEvent(of: .value, with: { (snapshot) in
                        //Fill in "BookInformation" node (currently does this every time a user is added as buyer/seller)
                        self.ref.child("Books").child(self.bookISBN).child("Book_Information").setValue(["Title": self.bookTitle, "Author": self.bookAuthor, "Date_Published": self.bookPublishDate, "Edition": "", "Photo_Cover": "\(uniquePostID).jpg"])
                        
                        // Append user info to "Buyer" node
                        self.ref.child("Books").child(self.bookISBN).child("Buyers").child(userID).child("User_Information").setValue(["User_Name": userFullName, "User_Location": bookZipCode])
                            
                        // Append post info to "Buyer" node
                        self.ref.child("Books").child(self.bookISBN).child("Buyers").child(userID).child("Posts").child(uniquePostID).setValue(["Post_Timestamp": date])
                    
                        
                    }) { (error) in
                        print("Error adding post to \"Books\" node")
                        print(error.localizedDescription)
                    }
                })
                self.dismiss(animated: true, completion: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController  else { assertionFailure("Couldn't find tab bar controller."); return }
                let tabBarController = [vc]
                self.navigationController?.setViewControllers(tabBarController, animated: false)
            }
            
        }
        
    }
    
    
    func createNewListing(userID: String, uniquePostID: String, date: String, timestamp: String, bookLocation: String){
        // make push call to database
        self.ref.child("Posts").child(uniquePostID).setValue(["Title": self.bookTitle, "Author": self.bookAuthor, "Date_Published": self.bookPublishDate, "Edition": "", "ISBN": self.bookISBN, "Condition": "", "User": userID, "Date_Posted": date, "Location": bookLocation, "User_Description": "Buyer", "Photo_Cover": "\(uniquePostID).jpg", "Time_Stamp": timestamp])
    }
    
    //    func getCityFromPostalCode(postalCode: String){
    func getCityFromPostalCode(postalCode: String, userID: String, uniquePostID: String, date: String, timestamp: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(postalCode) { results, error in
            
            // Placemark gives an array of best/closest results. First value of array most accurate.
            if let placemark = results?[0] {
                let locality = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                print(locality)
                print(state)
                
                
                let bookLocation = "\(locality), \(state)"
                print()
                self.createNewListing(userID: userID, uniquePostID: uniquePostID, date: date, timestamp: timestamp, bookLocation: bookLocation)
                
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    
    
    @IBAction func contactSellerButtonClicked(_ sender: Any) {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        
        if(self.userDescription == "Buyer"){
            controller.body = "Hello " + self.buyerSeller + ", I saw your request for " + self.bookTitle + " on Book Worm and I have a copy! Are you interested?"
        }else{
            controller.body = "Hello " + self.buyerSeller + ", I am interested in your listing for " + self.bookTitle + " on Book Worm."
        }

        self.ref.child("Users/\(self.buyerSellerID)").observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func wait() {
        self.activityindicator.startAnimating()
        self.view.alpha = 0.2
        self.view.isUserInteractionEnabled = false
    }
    
    func start() {
        self.activityindicator.stopAnimating()
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
    }
}
