//
//  ContactsViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ContactsViewController: UIViewController {
    
    let appColor = AppColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSettingsBarButton()
        createAddContactBarButton()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Settings
    func createSettingsBarButton() {
        let settingsButton = UIButton()
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.setTitleColor(appColor.green, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsPressed(_:)), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    @objc func settingsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSettings", sender: self)
    }
    
    //MARK: Add new contact
    func createAddContactBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewContactPressed))
    }
    
    @objc func addNewContactPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new contact", message: "Enter email below:", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (alertAction) in
            
            SVProgressHUD.show()
            
            if alert.textFields![0].text?.isEmpty == false {
                let newContactEmail = alert.textFields![0].text!

                Auth.auth().fetchProviders(forEmail: newContactEmail, completion: { (stringArray, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    } else {
                        if stringArray == nil {
                            print("No password. No active account")
                            SVProgressHUD.showError(withStatus: "There is no such user")
                        } else {
                            print("There is an active account")
                            
//TODO: add new conversation to contact list
                            
                            SVProgressHUD.showSuccess(withStatus: "New contact has been added")
                        }
                    }
                })
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

