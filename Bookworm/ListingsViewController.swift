//
//  ListingsViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//  Update by Urvashi Mahto on 2/22/21.

import UIKit
import Firebase

class ListingsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var listingsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    
    var placeholderTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderTitles.append("ECS 171 Textbook")
        placeholderTitles.append("ECS 150 Textbook")
        placeholderTitles.append("FMS 001 Textbook")
        self.searchBar.delegate = self
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        listingsTableView.reloadData()
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
        return placeholderTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell") ?? UITableViewCell(style: .default, reuseIdentifier: "listingCell")
        
        assert(indexPath.section == 0)
        cell.textLabel?.text = placeholderTitles[indexPath.row]
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
}
