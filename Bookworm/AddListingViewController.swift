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
        let uniqueBookID = UUID().uuidString
        
        var bookLocation = ""
        
        
        guard let userID = Auth.auth().currentUser?.uid else {
            assertionFailure("Couldn't unwrap userID")
            return
        }
        
        // save image to Firebase storage
        let imageRef = storageRef.child("\(uniqueBookID).jpg")
        
        //let bookCoverData = bookCoverImageM ?? UIImage(systemName: "book")
        
        
        
        // make push call to database
        //self.ref.child("Books").child(uniqueBookID).setValue(["Title": bookTitle, "Author": bookAuthor, "Date_Published": bookPublishDate, "Edition": "", "ISBN": bookISBN, "Condition": bookCondition, "User": userID, "Date_Posted": date, "Location": bookLocation, "User_Description": "Seller", "Photo_Cover": "\(uniqueBookID).jpg"])
        
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
    
    
}
