//
//  WishListListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class WishListListingViewController: UIViewController {

    @IBOutlet weak var removeFromWishlistButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var bookPublishDateLabel: UILabel!
    @IBOutlet weak var bookEditionLabel: UILabel!
    @IBOutlet weak var bookISBNLabel: UILabel!
    @IBOutlet weak var bookTitleLabel: UILabel!
    
    
    var bookAuthors: String = ""
    var bookCoverData: Data = Data()
    var bookISBN: String = ""
    var bookPublishDate: String = ""
    var bookEdition: String = ""
    var bookTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // format button + view
        removeFromWishlistButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
        wait()
        fillInPopup()
        start()    }
    
    func fillInPopup(){
        bookTitleLabel.text = self.bookTitle
        bookEditionLabel.text = "Edition: " + self.bookEdition
        bookISBNLabel.text = "ISBN: " + self.bookISBN
        bookAuthorLabel.text = "Authors: " + self.bookAuthors
        bookPublishDateLabel.text = "Publish Date: " + self.bookPublishDate
        bookCoverImage.image = UIImage(data: self.bookCoverData)
        
    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
