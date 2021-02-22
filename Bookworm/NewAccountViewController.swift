//
//  NewAccountViewController.swift
//  Bookworm
//
//  Created by Peter Kim on 2/21/21.
//

import UIKit
import FirebaseAuth


class NewAccountViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create tap gesture object for dismissing keyboard.
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // Add tap gesture to view.
        view.addGestureRecognizer(tapGesture)
        
        self.errorLabel.text = ""
        
        self.signUpButton.layer.cornerRadius = 18
        self.facebookButton.layer.cornerRadius = 18
        
        // For dot inputs for passwords
        self.passwordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.isSecureTextEntry = true
        
        // Change email textField to email keyboard
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        if (email == "" || password == "") {
            errorLabel.text = "Please fill in email and password."
            errorLabel.textColor = UIColor.systemRed
        } else if (email == "") {
            errorLabel.text = "Email cannot be empty"
            errorLabel.textColor = UIColor.systemRed
        } else if (password == "") {
            errorLabel.text = "Password cannot be empty"
            errorLabel.textColor = UIColor.systemRed
        } else if (confirmPassword == "") {
            errorLabel.text = "Confirm Password cannot be empty"
            errorLabel.textColor = UIColor.systemRed
        } else if (confirmPassword != password) {
            errorLabel.text = "Password does not match"
            errorLabel.textColor = UIColor.systemRed
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                if let authResult = authResult {
                    
                    print(authResult)
                    self.errorLabel.text = "Account created successfully"
                    self.errorLabel.textColor = UIColor.systemGreen
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let vc = storyboard.instantiateViewController(withIdentifier: "matchedViewController") as? MatchedViewController  else { assertionFailure("Couldn't find matched view controller."); return }
                    let matchedViewController = [vc]
                    self.navigationController?.setViewControllers(matchedViewController, animated: true)
                    
                } else if let error = error {
                    print(error)
                    
                    self.errorLabel.text = "\(error)"
                    self.errorLabel.textColor = UIColor.systemRed
                }
                
            }
        }
        
    }
}

