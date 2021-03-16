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

class MatchesEntryViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var transactionLabel: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var bookTitleTextField: UILabel!
    @IBOutlet weak var authorTextField: UILabel!
    @IBOutlet weak var publishingDateTextField: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var isbnTextField: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //format buttons + view
        contactButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
        
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
        let alert = UIAlertController(title: "Was <BOOK_TITLE> bought/sold from/to <USERNAME>?", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes, remove from wishlist/inventory", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, keep in wishlist/inventory", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
}
