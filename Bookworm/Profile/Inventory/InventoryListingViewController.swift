//
//  InventoryListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // format buttons + view
        uploadImageButton.layer.cornerRadius = 5
        removefromInventoryButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
        
        wait()
        fillInPopup()
        start()
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
    
    @IBAction func didPressSold(_ sender: Any) {
    }
    
    @IBAction func didPressRemove(_ sender: Any) {
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
