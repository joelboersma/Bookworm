//
//  InventoryListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class InventoryListingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressUploadImage(_ sender: Any) {
    }
    
    @IBAction func didPressSold(_ sender: Any) {
    }
    
    @IBAction func didPressRemove(_ sender: Any) {
    }
    
}
