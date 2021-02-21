//
//  ViewController.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/18/21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.errorLabel.text = ""
        
        loginButton.layer.cornerRadius = 18
        newAccountButton.layer.cornerRadius = 18
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func loginButtonPressed() {
        // Temporarily going to matched view controller to test location output.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "matchedViewController") as? MatchedViewController  else { assertionFailure("Couldn't find matched view controller."); return }
        let matchedViewController = [vc]
        self.navigationController?.setViewControllers(matchedViewController, animated: true)    }
    
}

