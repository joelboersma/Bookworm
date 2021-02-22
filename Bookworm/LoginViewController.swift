//
//  ViewController.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/18/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Create tap gesture object for dismissing keyboard.
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // Add tap gesture to view.
        view.addGestureRecognizer(tapGesture)
        
        self.errorLabel.text = ""
        
        loginButton.layer.cornerRadius = 18
        newAccountButton.layer.cornerRadius = 18
        
        // For dot inputs for password
        self.passwordTextField.isSecureTextEntry = true
        
        // Change email textField to email keyboard
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func loginButtonPressed() {
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        // Check for errors, else sign in successful
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
            } else {
                
// TODO: Erase commented section below if the updated tab bar implentation is correct
//                // Temporarily going to matched view controller to test location output.
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                guard let vc = storyboard.instantiateViewController(withIdentifier: "matchedViewController") as? MatchedViewController  else { assertionFailure("Couldn't find matched view controller."); return }
//                let matchedViewController = [vc]
//                self.navigationController?.setViewControllers(matchedViewController, animated: true)
                
                //switch to tab bar controller which will, by default, go to match view
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController  else { assertionFailure("Couldn't find tab bar controller."); return }
                let tabBarController = [vc]
                self.navigationController?.setViewControllers(tabBarController, animated: true)
            }
        }
        
        
    }
    
    @IBAction func newAccountButtonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "createAccountViewController")
        guard let newAccountVC = vc as? NewAccountViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        self.navigationController?.pushViewController(newAccountVC, animated: true)
    }
    
    
}

