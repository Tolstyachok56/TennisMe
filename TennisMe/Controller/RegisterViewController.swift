//
//  RegisterViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var loginTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: loginTextfield.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                print("Registrarion complete")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToContacts", sender: self)
            }
        }
    }
    
}
