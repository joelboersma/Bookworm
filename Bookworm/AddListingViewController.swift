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

class AddListingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var authorLabel: UITextField!
    @IBOutlet weak var publishDateLabel: UITextField!
    @IBOutlet weak var editionLabel: UITextField!
    @IBOutlet weak var isbnLabel: UITextField!
    
    var delegate: AddListingViewControllerDelegate?
    var isbn = "<ISBN_NUMBER>"
    var bookTitle: String = ""
    var bookAuthor:  String = ""
    var bookPublishDate: String = ""
    var bookISBN: String = ""
    var bookCoverImageS: Data? = nil
    var bookCoverImageM: Data? = nil
    var bookCoverImageL: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}
