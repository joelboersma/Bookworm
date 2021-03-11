//
//  AddPostViewController.swift
//  Bookworm
//
//  Created by Mohammed Haque on 3/8/21.
//

import UIKit
import Vision
import VisionKit

class AddPostBookCell: UITableViewCell {
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


class AddPostViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, VNDocumentCameraViewControllerDelegate {

    // Search API
    // https://openlibrary.org/dev/docs/api/search
    
    var books: [Book] = []
    var inputSearch: String = ""
    var recognizeTextRequest = VNRecognizeTextRequest()
    var recognizedText = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noSearchResultsLabel: UILabel!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        searchBar.delegate = self
        
        self.activityIndicator.stopAnimating()
        
        noSearchResultsLabel.text = ""
        
        recognizeTextHandler()
//        if !inputSearch.isEmpty {
//            searchBar.text = inputSearch
//            searchBarSearchButtonClicked(searchBar)
//            self.tapGestureRecognizer.isEnabled = false
//        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.tapGestureRecognizer.isEnabled = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.tapGestureRecognizer.isEnabled = false
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Clear "No Results Found Label
        noSearchResultsLabel.text = ""
            
        // Hide keyboard
        view.endEditing(true)
        
        // Clear books
        books.removeAll()
        self.resultsTableView.reloadData()
        
        // Search for new books
        if let searchText = searchBar.text {
            //display activity indicator
            self.wait()
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
                
                if responseWorks.count == 0{
                    self.noSearchResultsLabel.text = "No Results Found"
                }
                for work in responseWorks {
                    if self.books.count >= 25 {
//                        print("woohoo 25 books")
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
                                self.resultsTableView.reloadData()

                            }
                            
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
//                                    let coverM = coverResponse["imageData"] as? Data
//                                    book.coverImageM = coverM
                                    book.coverImageM = imageData
                                }
                                self.resultsTableView.reloadData()

                            }
// NOTE: not sure if it's necessary to get large image
//                            OpenLibraryAPI.cover(key: .ISBN, value: isbn, size: .L) { response, error in
//                                if let unwrappedError = error {
//                                    print("error finding cover")
//                                    print(unwrappedError)
//                                }
//                                else if let coverResponse = response {
//                                    let coverL = coverResponse["imageData"] as? Data
//                                    book.coverImageL = coverL
//                                }
//                            }
                        }
                    }
                }
                self.resultsTableView.reloadData()
                self.start()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addPostBookCell") as? AddPostBookCell else {
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
        let vc = storyboard.instantiateViewController(identifier: "addPostListingVC")
        guard let addPostListingVC = vc as? AddPostListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        addPostListingVC.bookAuthors = book.authors
        addPostListingVC.bookTitle = book.title
        addPostListingVC.bookISBN = book.isbn
        addPostListingVC.bookCoverImageS = book.coverImageS
        addPostListingVC.bookCoverImageM = book.coverImageM
        addPostListingVC.bookCoverImageL = book.coverImageL
    
        present(addPostListingVC,animated: true)
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        if sender.state == .ended {
            view.endEditing(true)
        }
    }
    
    @IBAction func scanBarcodePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "scannerVC")
        guard let scannerVC = vc as? ScannerViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        present(scannerVC, animated: true, completion: nil)
    }
    
    @IBAction func scanCoverPressed(_ sender: Any) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        self.present(documentCameraViewController, animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let image = scan.imageOfPage(at: 0)
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try handler.perform([recognizeTextRequest])
        } catch {
            print(error)
        }
        let ordinalNumberEndings = ["st", "nd", "rd", "th"]
        var recognizedTextArray = recognizedText.components(separatedBy: " ")
        let decimalDigits = CharacterSet.decimalDigits
        for (ind, str) in recognizedTextArray.enumerated() {
            let currStr = str.lowercased()
            if currStr.contains("edition") {
                recognizedTextArray[ind] = ""
                if ind > 0 {
                    if recognizedTextArray[ind - 1].rangeOfCharacter(from: decimalDigits) != nil || ordinalNumberEndings.filter({recognizedTextArray[ind - 1].lowercased().suffix(2).contains($0)}).count != 0 {
                        recognizedTextArray[ind - 1] = ""
                    }
                }
            }
        }
        
        let searchInputArray = recognizedTextArray.filter({$0 != ""})
        searchBar.text = searchInputArray.joined(separator: " ")
        searchBarSearchButtonClicked(searchBar)
        self.tapGestureRecognizer.isEnabled = false
        
        controller.dismiss(animated: true)
    }
    
    func recognizeTextHandler() {
        recognizeTextRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.recognizedText = ""
                    for observation in requestResults {
                        guard let candidiate = observation.topCandidates(1).first else { return }
//                        print(candidiate.string)
                        self.recognizedText += candidiate.string
                        self.recognizedText += " "
                    }
                }
            }
        })
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = true
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

