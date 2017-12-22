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
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    let appColor = AppColor()
    var contactsArray = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create Bar buttons
        createSettingsBarButton()
        createAddContactBarButton()
        
        // Set yourself as the delegate and datasource
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        // Register ContactCell.xib file
        contactsTableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "customContactCell")
        
        configureTableView()
        retrieveContacts()
        
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
        
        let currentUser = Auth.auth().currentUser
        
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
                    } else if stringArray == nil {
                        print("No password. No active account")
                        SVProgressHUD.showError(withStatus: "There is no such user")
                    } else {
                        print("There is an active account")
                            
                        //TODO: Add new ContactCell to TableView -> Method
                        
                        let contactsDB = Database.database().reference().child("Contacts").child((currentUser?.uid)!)
                        
                        //TODO: Cheking new contact for existing in contact list (DOUBLES)
                        
                        //  Add new contact in database
                        let contactDictionary = ["contactEmail" : newContactEmail]
                        contactsDB.childByAutoId().setValue(contactDictionary) { (error, reference) in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                            } else {
                                print("New contact has been added")
                                SVProgressHUD.showSuccess(withStatus: "New contact has been added")
                            }
                        }
                    }

                })
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Retrieve contacts
    func retrieveContacts() {
        let currentUser = Auth.auth().currentUser
        let contactsDB = Database.database().reference().child("Contacts").child((currentUser?.uid)!)
        
        contactsDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let contactEmail = snapshotValue["contactEmail"]!
            
            let contact = Contact()
            contact.email = contactEmail
            self.contactsArray.append(contact)
            
            self.configureTableView()
            self.contactsTableView.reloadData()
        }
        
    }
    
}

// MARK: TableView DataSource methods
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Cell for row in TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customContactCell", for: indexPath) as! CustomContactCell
        
        cell.avatarImageView.image = UIImage(named: "tennisMeDefaultAvatar")
        cell.contactName.text = contactsArray[indexPath.row].email
        return cell
    }
    
    // Number of rows in TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsArray.count
    }
    
    // Configure TableView
    func configureTableView() {
        contactsTableView.rowHeight = UITableViewAutomaticDimension
        contactsTableView.estimatedRowHeight = 64
    }
    
}

