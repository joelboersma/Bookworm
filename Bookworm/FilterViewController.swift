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
    @IBOutlet weak var categoryFilter: UISegmentedControl!
    
    var categorySegment0 = "Listings"
    var categorySegment1 = "Requests"
    var categorySegment2 = "Both"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryFilter.setTitle(categorySegment0, forSegmentAt: 0)
        categoryFilter.setTitle(categorySegment1, forSegmentAt: 1)
        categoryFilter.setTitle(categorySegment2, forSegmentAt: 2)
        
    }
    
    @IBAction func setFiltersButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
}
