//
//  ViewController.swift
//  AgriSmart_12
//
//  Created by student-2 on 02/12/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func navigateToOtherStoryboard(_ sender: UIButton) {
        // Instantiate the storyboard by its name
        let storyboard = UIStoryboard(name: "Farmer", bundle: nil)
        
        // Instantiate the view controller by its identifier
        let targetViewController = storyboard.instantiateViewController(withIdentifier: "farmer")
        
        // Present the target view controller
        self.present(targetViewController, animated: true, completion: nil)
    }
}
