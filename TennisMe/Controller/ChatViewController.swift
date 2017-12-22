//
//  ChatViewController.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    //MARK: Variables
    var contactEmail = String()
    var messageArray = [Message]()
    
    
    //MARK: METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set yourself as the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        // Register MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: do smth with title
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

            if sender == currentUserEmail || receiver == currentUserEmail {
                let message = Message()
                
                message.message = text
                message.sender = sender
                
                self.messageArray.append(message)
                
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
    }
    
    //TODO: Methods to send messages
    func sendMessage() {
        let currentUser = Auth.auth().currentUser
        
        let messageDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": currentUser?.email, "MessageBody": "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest", "Receiver": contactEmail]
        messageDB.childByAutoId().setValue(messageDictionary) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                
            }
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendMessage()
    }
    
}

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
