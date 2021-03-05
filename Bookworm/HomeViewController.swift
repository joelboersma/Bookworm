//
//  HomeViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 3/1/21.
//

import UIKit
import Firebase

class ListingsTableViewCell: UITableViewCell {
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var buyerSellerLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    
    var storageRef = Storage.storage().reference()
    
    func fillInBookCell (book: BookCell){
        
        // get book image reference from Firebase Storage
        let bookCoverRef = storageRef.child(book.bookCover)

        // download URL of reference, then get contents of URL and set imageView to UIImage
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
            self.bookCoverImage.image = image
        }
        
        self.bookTitleLabel.text = book.title
        self.conditionLabel.text = "Condition: \(book.condition)"
        self.locationLabel.text = book.location
        self.buyerSellerLabel.text = "\(book.userDescription): \(book.buyerSeller)"
        self.postDateLabel.text = book.postDate
        
    }
    
}


class HomeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var listingsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var books: [BookCell] = []
    
    var ref = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.searchBar.delegate = self
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        
        
        // For getting database data and reloadData for listingsTableView
        makeDatabaseCallsforReload()
        
        self.activityIndicator.stopAnimating()
        filterButton.layer.cornerRadius = 5
    }
    
    
    func makeDatabaseCallsforReload() {
        self.wait()
        self.ref.child("Books").queryOrdered(byChild: "Date_Posted").observe(.childAdded, with: { (snapshot) in
            let results = snapshot.value as? [String : String]
            var user = results?["User"] ?? ""
            let condition = results?["Condition"] ?? ""
            let isbn = results?["ISBN"] ?? ""
            let edition = results?["Edition"] ?? ""
            let author = results?["Author"] ?? ""
            let datePublished = results?["Date_Published"] ?? ""
            let datePosted = results?["Date_Posted"] ?? ""
            let location = results?["Location"] ?? ""
            let title = results?["Title"] ?? ""
            let userDescription = results?["User_Description"] ?? ""
            
            // Phooto_Cover from DB returns path in FBStorage
            let bookCover = results?["Photo_Cover"] ?? ""
            
            self.ref.child("Users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                let userData = snapshot.value as? [String: String]
                
                let firstName = userData?["FirstName"] ?? ""
                let lastName = userData?["LastName"] ?? ""
                
                user = firstName + " " + lastName
                
                let databaseData = BookCell(title: title, isbn: isbn, edition: edition, publishDate: datePublished, author: author, condition: condition, location: location, buyerSeller: user, postDate: datePosted, bookCover: bookCover, userDescription: userDescription)

                self.books.append(databaseData)
                
                DispatchQueue.main.async {
                    self.listingsTableView.reloadData()
                    self.start()
                }
                
            })
            
        })
        
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "filterVC")
        guard let filterVC = vc as? FilterViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        //filterVC.delegate = self
        
        present(filterVC, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
        // do Things For Searching
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: "listingsCell") as? ListingsTableViewCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        let book = books[indexPath.row]
        cell.fillInBookCell(book: book)
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let book = books[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "dblistingVC")
        guard let dblistingVC = vc as? DatabaseListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        dblistingVC.bookTitle = book.title
        dblistingVC.bookAuthor = book.author
        dblistingVC.bookEdition = book.edition
        dblistingVC.bookISBN = book.isbn
        dblistingVC.bookPublishDate = book.publishDate
        dblistingVC.bookCoverImage = book.bookCover
        
        //dblistingVC.delegate = self
        
        present(dblistingVC, animated: true, completion: nil)
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
