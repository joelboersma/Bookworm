//
//  InventoryViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class InventoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
   
    @IBOutlet weak var inventoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }

}
