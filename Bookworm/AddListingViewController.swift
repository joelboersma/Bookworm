//
//  AddListingViewController.swift
//  Bookworm
//
//  Created by Mohammed Haque on 3/1/21.
//

import Foundation
import CoreLocation
import UIKit
import Firebase

protocol AddListingViewControllerDelegate {
    func addListingVCDismissed()
}

class AddListingViewController: UIViewController {
    
    @IBOutlet weak var isbnLabel: UITextField!
    var isbn = "<ISBN_NUMBER>"
    var delegate: AddListingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isbnLabel.text = isbn
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            DispatchQueue.global(qos: .userInitiated).async { self.delegate?.addListingVCDismissed() }
        }
    }
}
