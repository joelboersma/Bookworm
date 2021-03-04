//
//  InventoryListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class InventoryListingViewController: UIViewController {

    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    
    @IBOutlet weak var removefromInventoryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // format buttons
        uploadImageButton.layer.cornerRadius = 5
        soldButton.layer.cornerRadius = 5
        removefromInventoryButton.layer.cornerRadius = 5
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
