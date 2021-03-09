//
//  WishListViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class WishListTableViewCell: UITableViewCell{
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!

    func fillInWishListCell(book: WishListBook){
        self.bookCoverImage.image = UIImage(data: book.bookCoverData)
        self.bookTitleLabel.text = book.title
        self.bookAuthorLabel.text = book.authors.joined(separator: ", ")
    }
}

class WishListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var wishListTableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var wishListBooks: [WishListBook] = []
    let storageRef = Storage.storage().reference()
    var ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wishListTableView.dataSource = self
        wishListTableView.delegate = self
        wishListTableView.reloadData()
        loadWishList()
    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addBookToDataSource(bookInfo: NSDictionary, isbn: String){
        guard let title = bookInfo.value(forKey: "Title") as? String, let authors = bookInfo.value(forKey: "Author") as? String, let publishDate = bookInfo.value(forKey: "Date_Published") as? String, let cover = bookInfo.value(forKey: "Photo_Cover") as? String else{
            print("error getting book data")
            return
        }
        let storageRef = Storage.storage().reference()

        // get book image reference from Firebase Storage
        let bookCoverRef = storageRef.child(cover)
        
        // download URL of reference, then get contents of URL and set imageView to UIImage
        bookCoverRef.downloadURL { url, error in
            guard let imageURL = url, error == nil else {
                print(error ?? "")
                return
            }
            
            guard let bookCoverData = NSData(contentsOf: imageURL) as Data? else {
                assertionFailure("Error in getting Data")
                return
            }
            let book = WishListBook(title: title, isbn: isbn, authors: [authors], publishDate: publishDate, bookCover: cover, bookCoverData: bookCoverData)
            self.wishListBooks.append(book)
            self.wishListTableView.reloadData()
        }
    }
    
    func loadWishList(){
        // Grab user ID from logged in user
        guard let userID = Auth.auth().currentUser?.uid else {
            assertionFailure("Couldn't unwrap userID")
            return
        }
        ref.child("Wishlists").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in

            //get wishlist content, fill in table view
            guard let wishlist = snapshot.value as? NSDictionary else {
                print("couldn't access user's wishlist")
                return
            }
            for postID in wishlist{
                if let isbnNode = postID.value as? [String: String], let isbn = isbnNode["ISBN"]{
//                    print(isbn)
                    // look up isbn in Books node for book info -> fill in table view cell
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.ref.child("Books").child(isbn).child("Book_Information").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let bookInfo = snapshot.value as? NSDictionary {
                                self.addBookToDataSource(bookInfo: bookInfo, isbn: isbn)
                            } else{
                                print("couldnt acess book information")
                            }
                            
                        }) { (error) in
                            print("error loading book info")
                            print(error.localizedDescription)
                        }
                    }
                }
            }
          }) { (error) in
            print("error loading wishlist")
            print(error.localizedDescription)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishListBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wishListCell", for: indexPath) as? WishListTableViewCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        let book = wishListBooks[indexPath.row]
        cell.fillInWishListCell(book: book)
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let book = wishListBooks[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "wishListListingViewController")
        guard let wishListListingVC = vc as? WishListListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        wishListListingVC.bookAuthors = book.authors.joined(separator: ", ")
        wishListListingVC.bookISBN = book.isbn
        wishListListingVC.bookTitle = book.title
        wishListListingVC.bookEdition = book.edition ?? ""
        wishListListingVC.bookCoverData = book.bookCoverData
        wishListListingVC.bookPublishDate = book.publishDate
        
        present(wishListListingVC, animated: true, completion: nil)
    
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
