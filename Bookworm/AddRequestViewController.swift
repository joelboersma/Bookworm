//
//  AddRequestViewController.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/26/21.
//

import UIKit

class AddRequestViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    // Search API
    // https://openlibrary.org/dev/docs/api/search
    
    var books: [Book] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard
        view.endEditing(true)
        
        // Clear books
        books.removeAll()
        self.resultsTableView.reloadData()
        
        // Search for new books
        if let searchText = searchBar.text {
            OpenLibraryAPI.search(searchText) { response, error in
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
                
                
                for work in responseWorks {
                    if self.books.count >= 25 {
                        print("woohoo 25 books")
                        break
                    }
                    if let title = work["title"] as? String,
                       let authors = work["author_name"] as? [String],
                       let isbns = (work["isbn"] as? [String])?.filter({ $0.count == 13 }) {
                        // Required: Title, author(s), and ISBN
                        // Optional: publish date, cover
                        // Publish date should be retrieved when user clicks on UITableView cell
                        for isbn in isbns {
                            if self.books.count >= 25 {
                                break
                            }
                            let book = Book(title: title, isbn: isbn, authors: authors, publishDate: nil)
                            self.books.append(book)
                            OpenLibraryAPI.cover(key: .ISBN, value: isbn, size: .S) { response, error in
                                if let unwrappedError = error {
                                    print("error finding cover")
                                    print(unwrappedError)
                                }
                                else if let coverResponse = response {
                                    let coverS = coverResponse["imageData"] as? Data
                                    book.coverImageS = coverS
                                }
                            }
                        }
                    }
                }
                self.resultsTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
//            assertionFailure("Cell dequeue error")
//            return UITableViewCell.init()
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "lapCell")
        let book = books[indexPath.row]
        cell.textLabel?.text = book.title
        return cell
    }
    

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        if sender.state == .ended {
            view.endEditing(true)
        }
    }
}
