//
//  MatchedEntryViewController.swift
//  Bookworm
//
//  Created by Mohammed Haque on 2/26/21.
//

import Foundation
import UIKit
import Firebase
import MessageUI

enum UserDescripton {
    case Buyer
    case Seller
}

class MatchesEntryViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var transactionButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var bookTitleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var publishingDateTextField: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var isbnTextField: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    var userID: String = ""
    var bookIndex: Int?
    var bookCondition: String = ""
    
    var myUserDescription: UserDescripton = .Seller
    
    var delegate: ReloadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //format buttons + view
        contactButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
        
        switch userDescription {
        case "Buyer":
            myUserDescription = .Buyer
            contactButton.setTitle("Contact Buyer", for: .normal)
            transactionButton.setTitle("Sold to This Buyer", for: .normal)
        case "Seller":
            myUserDescription = .Seller
            contactButton.setTitle("Contact Seller", for: .normal)
            transactionButton.setTitle("Bought From This Seller", for: .normal)
        default:
            assertionFailure("bad user description")
        }
        
        fillInBookInfo()
    }
    
    @IBAction func contactButtonPressed() {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.body = "Hello from Book Worm!"
        // using my phone number as placeholder
        controller.recipients = ["+1 510 403 5014"]
        if MFMessageComposeViewController.canSendText() {
            self.present(controller, animated: true, completion: nil)
        }
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
        
        self.bookTitleTextField.text = bookTitle
        self.authorTextField.text = "Author: \(bookAuthor)"
        self.publishingDateTextField.text = "Publish Date: \(bookPublishDate)"
        
        self.isbnTextField.text = "ISBN: \(bookISBN)"
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func transactionButtonPressed(_ sender: Any) {
        var userAction: String
        var removingFrom: String
        switch myUserDescription {
        case .Buyer:
            removingFrom = "inventory"
            userAction = "sold to"
        case .Seller:
            removingFrom = "wishlist"
            userAction = "purchased from"
        }
        
//        let alert = UIAlertController(title: "Confirmation", message: "Was \"\(bookTitle)\" \(userAction) \(buyerSeller)?", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes, remove from \(removingFrom)", style: .default, handler: removeFromInventoryOrWishlist))
//        alert.addAction(UIAlertAction(title: "Yes, but keep in \(removingFrom)", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "No, keep in \(removingFrom)", style: .cancel, handler: nil))
        
        let alert = UIAlertController(title: "Confirmation", message: "Would you like to remove \"\(bookTitle)\" from your \(removingFrom)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No, keep in \(removingFrom)", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, remove from \(removingFrom)", style: .destructive, handler: removeFromInventoryOrWishlist))

        self.present(alert, animated: true)
    }
    
    func removeFromInventoryOrWishlist(_ action: UIAlertAction) {
        switch myUserDescription {
        case .Buyer:
            removeItem(from: "Inventory", userStatus: "Sellers")
        case .Seller:
            removeItem(from: "Wishlist", userStatus: "Buyers")
        }
    }
    
    // copied/pasted from DataBaseListingVC
    func removeItem(from wishlistOrInventory: String, userStatus sellerOrBuyer: String) {
        self.wait()
        let postID = String(self.bookCoverImage.dropLast(4) as Substring)
        
        //remove book image from storage
        let imageRef = self.storageRef.child(self.bookCoverImage)
        imageRef.delete{ error in
            if error != nil {
              print("failed to delete image")
            }
            
            //Remove book from Posts
            self.ref.child("Posts/\(postID)").removeValue()
            
            //Remove book from Inventory or Wishlist
            self.ref.child("\(wishlistOrInventory)/\(self.userID)/\(postID)").removeValue()
            
            //Remove post from User's Seller/Buyer Node
            self.ref.child("Books/\(self.bookISBN)/\(sellerOrBuyer)/\(self.userID)/Posts/\(postID)").removeValue()
            
            //database- if user has no more posts of the book, remove the user entirely from the book
            self.ref.child("Books/\(self.bookISBN)/\(sellerOrBuyer)/\(self.userID)").observeSingleEvent(of: .value, with: { (snapshot) in

                // Get user value
                let numChildren = snapshot.childrenCount

                if numChildren == 1 {
                    self.ref.child("Books/\(self.bookISBN)/Buyers/\(self.userID)").removeValue()
                }
                //if there are no longer sellers or buyers  of the book, remove the book entirely from the database
                self.ref.child("Books/\(self.bookISBN)").observeSingleEvent(of: .value, with: { (snapshot) in
                  // Get user value
                    let numChildren = snapshot.childrenCount

                    if numChildren == 1 {
                        self.ref.child("Books/\(self.bookISBN)").removeValue()
                    }
                    
                    self.start()
                    if let bookIndex = self.bookIndex {
                        self.delegate?.reload(index: bookIndex)
                    }
                    
                    self.dismiss(animated: true, completion: nil)

                  }) { (error) in
                    print(error.localizedDescription)
                }
                
              }) { (error) in
                print(error.localizedDescription)
            }
        
        }
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
