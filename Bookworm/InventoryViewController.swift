//
//  InventoryViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class InventoryTableViewCell: UITableViewCell{
    @IBOutlet weak var bookTitleLabel: UILabel!

    @IBOutlet weak var bookCoverImage: UIImageView!
}

class InventoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var inventoryTableView: UITableView!
    
    var placeholderCells: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inventoryTableView.dataSource = self
        inventoryTableView.delegate = self
        inventoryTableView.reloadData()
        
        //add placeholder cells
        placeholderCells.append("ECS 198 Textbook")
        placeholderCells.append("FRE 21 Textbook")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inventoryCell", for: indexPath) as? InventoryTableViewCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        
        assert(indexPath.section == 0)
        cell.bookTitleLabel.text = placeholderCells[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "inventoryListingViewController")
        guard let inventoryListingVC = vc as? InventoryListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        present(inventoryListingVC, animated: true, completion: nil)
    }

    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
