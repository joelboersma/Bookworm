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
    @IBOutlet weak var bookEditionLabel: UITextField!
    @IBOutlet weak var bookISBNLabel: UITextField!
    @IBOutlet weak var addToWishlistButton: UIButton!
    
    var storageRef = Storage.storage().reference()
    
    var bookAuthor: String = ""
    var bookTitle: String = ""
    var bookPublishDate: String = ""
    var bookEdition: String = ""
    var bookISBN: String = ""
    var bookCoverImage: String = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //format buttons
        contactSellerButton.layer.cornerRadius = 5
        addToWishlistButton.layer.cornerRadius = 5
        
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
        
        if (bookEdition != ""){
            self.bookEditionLabel.text = "Edition: \(bookEdition)"
        } else {
            self.bookEditionLabel.text = "Edition: N/A"
        }
        
        self.bookISBNLabel.text = "ISBN: \(bookISBN)"
        
    }
    
    @IBAction func addToWishlistClicked(_ sender: Any) {
    }
    
    @IBAction func contactSellerButtonClicked(_ sender: Any) {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.body = "Hello from Book Worm!"
        // using my phone number as placeholder
        controller.recipients = ["+1 408 890 9988"]
        if MFMessageComposeViewController.canSendText() {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
