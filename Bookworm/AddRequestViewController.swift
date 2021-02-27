//
//  AddRequestViewController.swift
//  Bookworm
//
//  Created by Joel Boersma on 2/26/21.
//

import UIKit

class AddRequestViewController: UIViewController {

    // Search API
    // https://openlibrary.org/dev/docs/api/search
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
