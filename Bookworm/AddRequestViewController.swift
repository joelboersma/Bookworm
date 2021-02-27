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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard
        view.endEditing(true)
        
        // Do search functions here
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        return cell
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        if sender.state == .ended {
            view.endEditing(true)
        }
    }
}