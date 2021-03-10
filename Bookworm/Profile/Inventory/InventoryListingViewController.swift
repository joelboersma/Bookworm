//
//  InventoryListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

protocol ReloadAfterBookRemovalDelegate {
    func reloadAfterBookRemoval ()
}

class InventoryListingViewController: UIViewController {

    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var removefromInventoryButton: UIButton!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var bookISBNLabel: UILabel!
    @IBOutlet weak var bookEditionLabel: UILabel!
    @IBOutlet weak var bookPublishDateLabel: UILabel!
    @IBOutlet weak var bookConditionLabel: UILabel!
    
    var bookAuthors: String = ""
    var bookCoverData: Data = Data()
    var bookISBN: String = ""
    var bookPublishDate: String = ""
    var bookEdition: String = ""
    var bookTitle: String = ""
    var bookCondition: String = ""
    var bookPostID: String = ""
    var bookCover: String = ""
    
    var delegate: ReloadAfterBookRemovalDelegate?
    
    let storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // format buttons + view
        uploadImageButton.layer.cornerRadius = 5
        removefromInventoryButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
        
        self.wait()
        fillInPopup()
        self.start()
    }
    
    func fillInPopup(){
        bookTitleLabel.text = self.bookTitle
        bookEditionLabel.text = "Edition: " + self.bookEdition
        bookISBNLabel.text = "ISBN: " + self.bookISBN
        bookAuthorLabel.text = "Authors: " + self.bookAuthors
        bookPublishDateLabel.text = "Publish Date: " + self.bookPublishDate
        bookCoverImage.image = UIImage(data: self.bookCoverData)
        bookConditionLabel.text = "Book Condition: " + self.bookCondition
        
    }

    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressUploadImage(_ sender: Any) {
    
    }
    
    
    @IBAction func didPressRemove(_ sender: Any) {
        // Grab user ID from logged in user
        guard let userID = Auth.auth().currentUser?.uid else {
            assertionFailure("Couldn't unwrap userID")
            return
        }
        
        
        //database- remove post from "Posts"
        self.ref.child("Posts/\(self.bookPostID)").removeValue()
        
        //database- remove book from user's inventory in "Inventories"
        self.ref.child("Inventories/\(userID)/\(self.bookPostID)").removeValue()
        
        //database- remove post from user's node in "Books" -> "Sellers" -> User ID
        self.ref.child("Books/\(self.bookISBN)/Sellers/\(userID)/Posts/\(self.bookPostID)").removeValue()
        
        //database- if user has no more posts of the book, remove the user entirely from the book
        ref.child("Books/\(self.bookISBN)/Sellers/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let numChildren = snapshot.childrenCount

            if numChildren == 1 {
                self.ref.child("Books/\(self.bookISBN)/Sellers/\(userID)").removeValue()
            }
            //if there are no longer sellers or buyers  of the book, remove the book entirely from the database
            self.ref.child("Books/\(self.bookISBN)").observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                let numChildren = snapshot.childrenCount

                if numChildren == 1 {
                    self.ref.child("Books/\(self.bookISBN)").removeValue()
                }
              }) { (error) in
                print(error.localizedDescription)
            }

          }) { (error) in
            print(error.localizedDescription)
        }

        
        //database- remove book image from storage
        let imageRef = self.storageRef.child(self.bookCover)
        imageRef.delete(completion: nil)
        
        //call delegate which will reload inventory data
        self.delegate?.reloadAfterBookRemoval()
        
        //dismiss the view and reload data
        self.dismiss(animated: true, completion: nil)
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
