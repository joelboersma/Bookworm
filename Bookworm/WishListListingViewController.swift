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
    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // format button + view
        removeFromWishlistButton.layer.cornerRadius = 5
        popupView.layer.cornerRadius = 10
    }
    
    @IBAction func didPressX(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressRemove(_ sender: Any) {
    }
    
}
