//
//  AddRequestViewController.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/26/21.
//

import UIKit

class AddRequestBookCell: UITableViewCell {
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorsLabel: UILabel!
    @IBOutlet weak var bookPublishDateLabel: UILabel!
    
    func fillInBookCell (book: Book){
        
        //fill in book cover if available
        if let coverImageDataM = book.coverImageM, let coverImageM = UIImage(data: coverImageDataM) {
            self.bookCoverImage.image = coverImageM
        } else if let coverImageDataS = book.coverImageS, let coverImageS = UIImage(data: coverImageDataS) {
            self.bookCoverImage.image = coverImageS
        } else if let coverImageDataL = book.coverImageL, let coverImageL = UIImage(data: coverImageDataL) {
            self.bookCoverImage.image = coverImageL
        } else {
            self.bookCoverImage.image = UIImage(systemName: "book")
        }
        
        //fill in book title
        self.bookTitleLabel.text = book.title
        
        //fill in book publish date if available
        if let bookPublishDate = book.publishDate {
            self.bookPublishDateLabel.text = "Publish Date: " + bookPublishDate
        } else {
            self.bookPublishDateLabel.text = ""
        }

        //fill in book author
        self.bookAuthorsLabel.text = "Authors: " + book.authors.joined(separator: ", ")
    }
}


class AddRequestViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    // Search API
    // https://openlibrary.org/dev/docs/api/search
    
    var books: [Book] = []
    var latestSearchResponse: [[String : Any]] = [[:]]
    var currentQuery = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noSearchResultsLabel: UILabel!
    @IBOutlet weak var bigSearchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.isHidden = true
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        searchBar.delegate = self
        
        self.activityIndicator.stopAnimating()
        
        noSearchResultsLabel.text = ""
    }
    
    func getResults(num: Int, query: String) {
        OpenLibraryAPI.search(query) { response, error in
            if query != self.currentQuery { return }
            if let unwrappedError = error {
                print("search error")
                print(unwrappedError)
                return
            }
            guard let unwrappedResponse = response else {
                print("no response")
                return
            }
            guard let responseWorks = unwrappedResponse["docs"] as? [[String:Any]] else {
                print("bad docs response")
                return
            }
            
            if responseWorks.count == 0 {
                self.noSearchResultsLabel.text = "No Results Found"
                return
            }
            var queryBooks: [Book] = []
            for work in responseWorks {
                if query != self.currentQuery { return }
                else if self.books.count >= num {
                    print("search done: " + query)
//                    self.books = queryBooks
                    self.resultsTableView.reloadData()
                    break
                }
                if let title = work["title"] as? String,
                   let authors = work["author_name"] as? [String],
                   let isbns = (work["isbn"] as? [String])?.filter({ $0.count == 13 }) {
                    // Required: Title, author(s), and ISBN 13
                    // Optional: publish date, cover
                    // Publish date should be retrieved when user clicks on UITableView cell
                    for isbn in isbns {
                        if query != self.currentQuery { return }
                        else if self.books.count >= num {
                            break
                        }
                        let book = Book(title: title, isbn: isbn, authors: authors, publishDate: nil)
                        self.books.append(book)
                        self.resultsTableView.reloadData()
                        
                        //get medium sized cover for the add request listing view
                        OpenLibraryAPI.cover(key: .ISBN, value: isbn, size: .M) { response, error in
                            if let unwrappedError = error {
                                print("error finding cover")
                                print(unwrappedError)
                            }
                            else if let coverResponse = response {
                                guard let imageData: Data = coverResponse["imageData"] as? Data else {
                                    print("bad image data")
                                    return
                                }
                                book.coverImageM = imageData
                            }
                            self.resultsTableView.reloadData()
                        }
                    }
                }
            }
            self.resultsTableView.reloadData()
            self.start()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.tapGestureRecognizer.isEnabled = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.tapGestureRecognizer.isEnabled = false
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        currentQuery = searchText
        books.removeAll()
        resultsTableView.reloadData()
        noSearchResultsLabel.text = ""
        if searchText.filter({!$0.isWhitespace}).isEmpty {
            bigSearchLabel.isHidden = false
            resultsTableView.isHidden = true
        }
        else {
            bigSearchLabel.isHidden = true
            resultsTableView.isHidden = false
            getResults(num: 25, query: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard
        view.endEditing(true)
    }
    
    // table view scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Hide keyboard
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addRequestBookCell") as? AddRequestBookCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        
        let book = books[indexPath.row]
        cell.fillInBookCell(book: book)
        cell.layer.cornerRadius = 5
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = books[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "addRequestListingViewController")
        guard let addRequestListingVC = vc as? AddRequestListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        addRequestListingVC.bookAuthors = book.authors
        addRequestListingVC.bookTitle = book.title
        addRequestListingVC.bookISBN = book.isbn
        addRequestListingVC.bookCoverImageS = book.coverImageS
        addRequestListingVC.bookCoverImageM = book.coverImageM
        addRequestListingVC.bookCoverImageL = book.coverImageL
    
        present(addRequestListingVC,animated: true)

    }
    

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        if sender.state == .ended {
            view.endEditing(true)
        }
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


