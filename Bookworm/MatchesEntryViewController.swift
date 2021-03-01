//
//  MatchedEntryViewController.swift
//  Bookworm
//
//  Created by Mohammed Haque on 2/26/21.
//

import Foundation
import UIKit
import Firebase
import MessageUI

class MatchesEntryViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var transactionButton: UIButton!
    @IBOutlet weak var transactionLabel: UITextField!
    
    var isCurrentTable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after lsoading the view.
        if isCurrentTable {
            transactionLabel.isHidden = true
            transactionButton.isHidden = false
        }
        else {
            transactionLabel.isHidden = false
            transactionButton.isHidden = true
        }
    }
    
    @IBAction func contactButtonPressed() {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.body = "Hello from Book Worm!"
        // using my phone number as placeholder
        controller.recipients = ["+1 510 403 5014"]
        if MFMessageComposeViewController.canSendText() {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func xButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func transactionButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Was <BOOK_TITLE> bought/sold from/to <USERNAME>?", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes, remove from wishlist/inventory", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, keep in wishlist/inventory", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
}
