//
//  AddRequestViewController.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/26/21.
//

import UIKit

class AddRequestViewController: UIViewController, UISearchBarDelegate {

    // Search API
    // https://openlibrary.org/dev/docs/api/search
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Do search functions here
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
