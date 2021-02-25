//
//  FilterViewController.swift
//  Bookworm
//
//  Created by Urvashi Mahto on 2/24/21.
//

import Foundation
import UIKit
import Firebase

class FilterViewController: UIViewController {
    @IBOutlet weak var setFiltersButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setFiltersButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
