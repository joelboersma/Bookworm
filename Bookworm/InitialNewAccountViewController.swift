//
//  InitialNewAccountViewController.swift
//  Bookworm
//
//  Created by Peter Kim on 2/25/21.
//

import UIKit

class InitialNewAccountViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create tap gesture object for dismissing keyboard.
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // Add tap gesture to view.
        view.addGestureRecognizer(tapGesture)
        
        self.errorLabel.text = ""
        
        self.continueButton.layer.cornerRadius = 18
    }
    
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let phoneNumber = phoneNumberTextField.text ?? ""
        let zipCode = zipCodeTextField.text ?? ""
        
        if (firstName == "" || lastName == "" || phoneNumber == "" || zipCode == "") {
            errorLabel.text = "Missing field(s), please try again"
            errorLabel.textColor = UIColor.systemRed
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "createAccountViewController")
            guard let newAccountVC = vc as? NewAccountViewController else {
                assertionFailure("couldn't find vc")
                return
            }
            self.navigationController?.pushViewController(newAccountVC, animated: true)
            
        }
        
        
    }
    
}
