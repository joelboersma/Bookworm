//
//  AddRequestListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 3/2/21.
//

import UIKit

class AddRequestListingViewController: UIViewController {
    
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookAuthorLabel: UITextField!
    @IBOutlet weak var bookPublishDateLabel: UITextField!
    @IBOutlet weak var bookEditionLabel: UITextField!
    @IBOutlet weak var bookISBNLabel: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addRequestButton: UIButton!
    
    var bookAuthors: [String] = []
    var bookTitle: String = ""
    var bookISBN: String = ""
    var bookCoverImageS: Data? = nil
    var bookCoverImageM: Data? = nil
    var bookCoverImageL: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //format button
        addRequestButton.layer.cornerRadius = 5
        fillInBookInfo()
    }
    
    func fillInBookInfo (){
        //fill in book cover if available
        if let coverImageDataM = bookCoverImageM, let coverImageM = UIImage(data: coverImageDataM) {
            self.bookCoverImage.image = coverImageM
        } else if let coverImageDataS = bookCoverImageS, let coverImageS = UIImage(data: coverImageDataS) {
            self.bookCoverImage.image = coverImageS
        } else if let coverImageDataL = bookCoverImageL, let coverImageL = UIImage(data: coverImageDataL) {
            self.bookCoverImage.image = coverImageL
        } else {
            self.bookCoverImage.image = UIImage(systemName: "book")
        }
        
        
        //fill in book title
        self.bookTitleLabel.text = bookTitle
        
        //fill in book publish date if available
        self.wait()
        OpenLibraryAPI.ISBN(bookISBN, completion: { response, error in
            if let unwrappedError = error {
                print("search error")
                print(unwrappedError)
                return
            }
            guard let unwrappedResponse = response else {
                print("no response")
                return
            }
            
            if let publishDate = unwrappedResponse["publish_date"] as? String {
                self.bookPublishDateLabel.text = "Publish Date: " + publishDate
            } else {
                self.bookPublishDateLabel.text = "Publish Date: None found"
            }
            self.start()
        })
        
        //fill in book author
        self.bookAuthorLabel.text = bookAuthors.reduce("Authors:"){$0 + " " + $1}
        
        //fill in book isbn
        self.bookISBNLabel.text = "ISBN: " + bookISBN
    }
    

    @IBAction func didPressAddRequest(_ sender: Any) {
    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //following two functions taken from hw solutions
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
