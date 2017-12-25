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
    
    //MARK: Constants
    let appColor = AppColor()
    
    //Segue Identifiers
    let settingsSegueID = "goToSettings"
    let chatSegueID = "goToChat"
    
    //Contact Cell Identifier
    let contactCellID = "customContactCell"
    
    
    //MARK: IBOutlets
    @IBOutlet weak var contactsTableView: UITableView!
    
    //MARK: Variables
    var contactsArray = [Contact]()
    
    
    //MARK: METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create Bar buttons
        createSettingsBarButton()
        createAddContactBarButton()
        
        // Set yourself as the delegate and datasource
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        // Register ContactCell.xib file
        contactsTableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: contactCellID)
        
        retrieveContacts()
        
    }
    
    //BAR BUTTONS
    
    //Settings
    func createSettingsBarButton() {
        let settingsButton = UIButton()
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.setTitleColor(appColor.green, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsPressed(_:)), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    @objc func settingsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: settingsSegueID, sender: self)
    }
    
    //Add new contact
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
                        print(stringArray as Any)
                        
                        //TODO: Check new contact for existing in contact list (DOUBLES)
                        
                        //  Add new contact in database
                        self.addNewContactToDB(currentUser: currentUser, newContactEmail: newContactEmail)
                    }

                })
                
            } else {
                print("TextField is empty")
                SVProgressHUD.showError(withStatus: "You did not enter email")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Add new contact in database
    func addNewContactToDB (currentUser: User?, newContactEmail: String) {
        
        let contactDictionary = ["contactEmail" : newContactEmail]
        let contactsDB = Database.database().reference().child("Contacts").child((currentUser?.uid)!)
        
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
            
           // self.configureTableView()
            self.contactsTableView.reloadData()
        }
        
    }
    
    // Segue to chat
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == chatSegueID {
            if let contactIndex = self.contactsTableView.indexPathForSelectedRow {
                let destination = segue.destination as? ChatViewController
                
            // Data -> Chat
                destination?.contactEmail = self.contactsArray[contactIndex.row].email
            }
        }
    }
    
}

// MARK: TableView DataSource and Delegate methods
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Cell for row in TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellID, for: indexPath) as! CustomContactCell
        
        cell.avatarImageView.image = UIImage(named: "tennisMeDefaultAvatar")
        cell.contactName.text = contactsArray[indexPath.row].email
        return cell
    }
    
    // Number of rows in TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsArray.count
    }
    
    // Height for row in TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    // Select row -> segue to chat
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: chatSegueID, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        print("Segue to chat with contact: \(contactsArray[indexPath.row].email)")
    }
    
}

