//
//  ChatViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: Variables
    var contactEmail = String()
    var messageArray = [Message]()
    
    var keyboardHeight: CGFloat = 0
    
    
    //MARK: METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set yourself as the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        // Set yourself as the delegate of TextField
        messageTextField.delegate = self
        
        // Register MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = contactEmail
    }
    
    // Retrieve messages
    func retrieveMessages() {
        let currentUserEmail = Auth.auth().currentUser?.email
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let receiver = snapshotValue["Receiver"]!

            if (sender == currentUserEmail && receiver == self.contactEmail) ||
                (sender == self.contactEmail && receiver == currentUserEmail) {
                
                let message = Message()
                
                message.message = text
                message.sender = sender
                
                self.messageArray.append(message)
                
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
    }
    
    // Send message
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        messageTextField.endEditing(true)
        
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let text = messageTextField.text!
        let currentUser = Auth.auth().currentUser
        let messageDictionary = ["Sender": currentUser?.email,
                                 "Receiver": contactEmail,
                                 "MessageBody": text]
        
        let messageDB = Database.database().reference().child("Messages")
        messageDB.childByAutoId().setValue(messageDictionary) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                self.messageTextField.text = ""
            }
        }
        
        messageTextField.isEnabled = true
        sendButton.isEnabled = true
    }
    
}

////////////////////////////////////
//MARK: TableView DataSource methods

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Cell for row in TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageAvatarImageView.image = UIImage(named: "tennisMeDefaultAvatar")
        cell.messageBody.text = messageArray[indexPath.row].message
        cell.senderUserName.text = messageArray[indexPath.row].sender
        return cell
    }
    
    // Number of rows in TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    // Configure TableView
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
}

//////////////////////////////////
//MARK: TextField Delegate methods
extension ChatViewController: UITextFieldDelegate {
    
    // Keyboard shows
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = self.keyboardHeight + 42
            self.view.layoutIfNeeded()
        }
    }
    
    // Keyboard hides
    @objc func keyboardWillHide(notification: Notification) {}
    
    // Begin editing TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    // End editing TextField
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 42
            self.view.layoutIfNeeded()
        }
    }
    
}
