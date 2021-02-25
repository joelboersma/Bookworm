//
//  DatabaseListingViewController.swift
//  Bookworm
//
//  Created by Urvashi Mahto on 2/23/21.
//

import Foundation
import UIKit
import Firebase
import MessageUI

class DatabaseListingViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var contactSellerButton: UIButton!

    @IBOutlet weak var xButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func contactSellerButtonClicked(_ sender: Any) {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.body = "Hello from Book Worm!"
        // using my phone number as placeholder
        controller.recipients = ["+1 408 890 9988"]
        if MFMessageComposeViewController.canSendText() {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
