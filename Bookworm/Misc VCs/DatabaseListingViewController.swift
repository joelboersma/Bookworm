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

class DatabaseListingViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var contactSellerButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookAuthorLabel: UITextField!
    @IBOutlet weak var bookPublishingDateLabel: UITextField!
    @IBOutlet weak var bookISBNLabel: UITextField!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    
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
    
    @IBAction func xButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
