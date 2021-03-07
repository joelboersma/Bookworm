//
//  WishListViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit

class WishListTableViewCell: UITableViewCell{
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var bookPublishDateLabel: UILabel!
}

class WishListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var wishListTableView: UITableView!
    
    var placeholderCells: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wishListTableView.dataSource = self
        wishListTableView.delegate = self
        wishListTableView.reloadData()
        
        //add placeholder cells
        placeholderCells.append("ECS 198 Textbook")
        placeholderCells.append("FRE 21 Textbook")
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wishListCell", for: indexPath) as? WishListTableViewCell else {
            assertionFailure("Cell dequeue error")
            return UITableViewCell.init()
        }
        assert(indexPath.section == 0)
        cell.bookTitleLabel.text = placeholderCells[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "wishListListingViewController")
        guard let wishListListingVC = vc as? WishListListingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        
        present(wishListListingVC, animated: true, completion: nil)
    }
    
    
}
