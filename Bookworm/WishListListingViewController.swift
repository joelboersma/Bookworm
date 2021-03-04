//
//  WishListListingViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class WishListListingViewController: UIViewController {

    @IBOutlet weak var removeFromWishlistButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // format button
        removeFromWishlistButton.layer.cornerRadius = 5
    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressRemove(_ sender: Any) {
    }
    
}
