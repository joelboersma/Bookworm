//
//  ProfileViewController.swift
//  Bookworm
//
//  Created by Christina Luong on 2/22/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UITextField!
    
    //get references to all buttons (for formatting)
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var inventoryButton: UIButton!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var editUsernameButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make all buttons rounded
        formatButton(logoutButton)
        formatButton(inventoryButton)
        formatButton(wishListButton)
        formatButton(editUsernameButton)
        formatButton(deleteAccountButton)

    }
    
    func formatButton(_ button: UIButton) {
        button.layer.cornerRadius = 18
    }
    
    func returnToLoginView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController  else { assertionFailure("Couldn't find login view controller."); return }
        let loginViewController = [vc]
        self.navigationController?.setViewControllers(loginViewController, animated: true)
    }
    
    @IBAction func didPressLogout(_ sender: Any) {
        //re-set navication controller to login view
        returnToLoginView()
    }
    
    @IBAction func didPressInventory(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "inventoryViewController") as? InventoryViewController  else { assertionFailure("Couldn't find inventory view controller."); return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didPressWishList(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "wishListViewController") as? WishListViewController  else { assertionFailure("Couldn't find wish list view controller."); return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func didPressEditUsername(_ sender: Any) {
    }
    
    @IBAction func didPressDeleteAccount(_ sender: Any) {
        let user = Auth.auth().currentUser
        
        //user must confirm deletion before account is actually deleted
        let confirmDeleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this account?", preferredStyle: .alert)
        
        //if user confirms deletion, account is deleted and screen returns to login view
        confirmDeleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
            user?.delete {error in
                if let err = error{ print(err)}
            }
            self.returnToLoginView()
        }))
        
        //if user does not confirm deletion, screen returns to profile view
        confirmDeleteAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(confirmDeleteAlert,animated: true)
    }
}
