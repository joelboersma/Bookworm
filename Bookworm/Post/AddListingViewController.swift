//
//  AddListingViewController.swift
//  Bookworm
//
//  Created by Mohammed Haque on 3/1/21.
//

import Foundation
import CoreLocation
import UIKit
import Firebase

protocol AddListingViewControllerDelegate {
    func addListingVCDismissed()
}

class AddListingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var uplaodImagesButton: UIButton!
    @IBOutlet weak var addListingButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var authorLabel: UITextField!
    @IBOutlet weak var publishDateLabel: UITextField!
    @IBOutlet weak var editionLabel: UITextField!
    @IBOutlet weak var isbnLabel: UITextField!
    
    @IBOutlet weak var bookConditionPickerView: UIPickerView!
    
    var storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    
    var delegate: AddListingViewControllerDelegate?
    var isbn = "<ISBN_NUMBER>"
    var bookTitle: String = ""
    var bookAuthor:  String = ""
    var bookPublishDate: String = ""
    var bookISBN: String = ""
    var bookCondition: String = ""
    var bookLocation: String = ""
    var bookCoverImageS: Data? = nil
    var bookCoverImageM: Data? = nil
    var bookCoverImageL: Data? = nil
    
    var bookConditionPickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format buttons + view
        popupView.layer.cornerRadius = 10
        uplaodImagesButton.layer.cornerRadius = 5
        addListingButton.layer.cornerRadius = 5
        
        // connect data
        self.bookConditionPickerView.delegate = self
        self.bookConditionPickerView.dataSource = self
        
        // put book conditions into array
        bookConditionPickerData = ["Poor", "Fair", "Good", "Great", "New"]
        
        // if user doesn't touch UIPicker, default saved valuee is Poor
        self.bookCondition = bookConditionPickerData[0] as String
        
        titleLabel.text = bookTitle
        if let coverImageDataM = bookCoverImageM, let coverImageM = UIImage(data: coverImageDataM) {
            coverImageView.image = coverImageM
        }
        else {
            coverImageView.image = UIImage(systemName: "book")
        }
        authorLabel.text = "Author: " + bookAuthor
        publishDateLabel.text = "Publish Date: " + bookPublishDate
        isbnLabel.text = "ISBN: " + bookISBN
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            DispatchQueue.global(qos: .userInitiated).async { self.delegate?.addListingVCDismissed() }
        }
    }
    
    @IBAction func didPressUploadImages(_ sender: Any) {
        
        
        
    }
    
    @IBAction func didPressAddListing(_ sender: Any) {
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let date = formatter.string(from: currentDateTime)
        let uniquePostID = UUID().uuidString

        
        // save image to Firebase storage with uniqueBookID.jpg as image path
        let imageRef = storageRef.child("\(uniquePostID).jpg")
        
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
        }
        
        // Grab user ID from logged in user
        guard let userID = Auth.auth().currentUser?.uid else {
            assertionFailure("Couldn't unwrap userID")
            return
        }
        
        //add book isbn to user's inventory
        ref.self.ref.child("Inventories").child(userID).child(uniquePostID).setValue(["ISBN": self.bookISBN])

        
        // Grab zipcode from user
        self.ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userData = snapshot.value as? [String: String]
            let bookZipCode = userData?["ZipCode"] ?? ""
            
            //change zip code to city and push new post onto database "Posts"
            self.getCityFromPostalCode(postalCode: bookZipCode, userID: userID, uniquePostID: uniquePostID, date: date)
            
            //TODO: add user as seller under "Books"-> (isbn) -> Sellers" (should include UserID -> condition, location, date posted)
                        
            
            //TODO: Erase section of code below if location implementation was updated correctly
//            self.getCityFromPostalCode(postalCode: bookZipCode)
//
//            // make push call to database
//            self.ref.child("Books").child(uniqueBookID).setValue(["Title": self.bookTitle, "Author": self.bookAuthor, "Date_Published": self.bookPublishDate, "Edition": "", "ISBN": self.bookISBN, "Condition": self.bookCondition, "User": userID, "Date_Posted": date, "Location": self.bookLocation, "User_Description": "Seller", "Photo_Cover": "\(uniqueBookID).jpg"])
//
            
        })
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bookConditionPickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bookConditionPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        bookCondition = bookConditionPickerData[row] as String
    }
    
    func createNewListing(userID: String, uniquePostID: String, date: String){
        // make push call to database
        self.ref.child("Posts").child(uniquePostID).setValue(["Title": self.bookTitle, "Author": self.bookAuthor, "Date_Published": self.bookPublishDate, "Edition": "", "ISBN": self.bookISBN, "Condition": self.bookCondition, "User": userID, "Date_Posted": date, "Location": self.bookLocation, "User_Description": "Seller", "Photo_Cover": "\(uniquePostID).jpg"])
    }

//    func getCityFromPostalCode(postalCode: String){
    func getCityFromPostalCode(postalCode: String, userID: String, uniquePostID: String, date: String) {

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(postalCode) { results, error in
            
            // Placemark gives an array of best/closest results. First value of array most accurate.
            if let placemark = results?[0] {
                let locality = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                print(locality)
                print(state)
                
                
                self.bookLocation = "\(locality), \(state)"
                print()
                self.createNewListing(userID: userID, uniquePostID: uniquePostID, date: date )
                
            }
            if let error = error {
                print(error)
                self.bookLocation = "Did not Work"
            }
        }
    }
    
    
}
