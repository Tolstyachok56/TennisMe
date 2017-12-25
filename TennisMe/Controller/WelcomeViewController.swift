//
//  ViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 06.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    //MARK: testing email and password
    let defaultEmail = ""
    let defaultPassword = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Testing login from welcome screen
        if defaultEmail != "" && defaultPassword != "" {
            Auth.auth().signIn(withEmail: defaultEmail, password: defaultPassword) { (user, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                } else {
                    print("Fast login successful")
                self.performSegue(withIdentifier: "goToContacts", sender: self)
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

