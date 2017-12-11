//
//  SettingsViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
        
        guard(navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("No View Controllers to pop off")
                return
        }
    }
    
    
    
}
