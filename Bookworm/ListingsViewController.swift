//
//  ListingsViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//  Update by Urvashi Mahto on 2/22/21.

import UIKit
import Firebase

class ListingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var listingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
}
