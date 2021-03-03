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
    
    func fillInBookCell (book: BookCell){
        self.bookCoverImage.image = UIImage(systemName: "book")
        self.bookTitleLabel.text = book.title
        self.conditionLabel.text = "Condition: \(book.condition)"
        self.locationLabel.text = book.location
        self.buyerSellerLabel.text = book.buyerSeller
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
        
    }
    
    
    func makeDatabaseCallsforReload() {
        self.wait()
        self.ref.child("Books").child("Requests").queryOrdered(byChild: "Posted_Date").observe(.childAdded, with: { (snapshot) in
            let results = snapshot.value as? [String : String]
            var buyer = results?["Buyer"] ?? ""
            let condition = results?["Condition"] ?? ""
            let datePosted = results?["Posted_Date"] ?? ""
            let location = results?["Location"] ?? ""
            let title = results?["Title"] ?? ""
            
            self.ref.child("Users").child(buyer).observeSingleEvent(of: .value, with: { (snapshot) in
                let buyerData = snapshot.value as? [String: String]
                
                let firstName = buyerData?["FirstName"] ?? ""
                let lastName = buyerData?["LastName"] ?? ""
                
                buyer = firstName + " " + lastName
                
                let databaseData = BookCell(title: title, condition: condition, location: location, buyerSeller: buyer, postDate: datePosted)
                
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        // empty dblistingVC for now
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "dblistingVC")
        guard let dblistingVC = vc as? DatabaseListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
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
