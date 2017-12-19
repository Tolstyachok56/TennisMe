//
//  LogInViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {
    
    
    @IBOutlet weak var loginTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: loginTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                print("Login successful")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToContacts", sender: self)
            }
        }
    }
    
}
