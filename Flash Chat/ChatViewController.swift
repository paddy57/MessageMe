//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // Declare instance variables here

    var messageArray : [Message] = [Message]()
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        
        messageTableView.delegate = self
        
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:

        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped) )
        messageTableView.addGestureRecognizer(tapGesture)
        
        

        //TODO: Register your MessageCell.xib file here:
        //we need this to create our own customm cell
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil),
                                  forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        retrieveMessages()
        
        //to remove seprator between message
        messageTableView.separatorStyle = .none

        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    //we need this to create our own customm cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        //cell means each index of the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        //teriving data from messageArray
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        //setting up the profile
        cell.avatarImageView.image = UIImage(named: "egg")
        
        //when message sent by us change back color of message
        if cell.senderUsername.text == FIRAuth.auth()?.currentUser?.email as String!{
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else{
        
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        
        }
        return cell
    }
    
    
    
    //TODO: Declare numberOfRowsInSection here:
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    //to end keyboard
    func tableViewTapped(){
    
    messageTextfield.endEditing(true)
    
    
    }
    
    
    
    //TODO: Declare configureTableView here:
    //to dyanamically incesase height of the table view cell
    
    func configureTableView(){
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
        
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    // to increase height of text field when user gonna type this
    //TODO: Declare textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        //to add animation
        
        UIView.animate(withDuration: 0.5) {
        
            self.heightConstraint.constant = 308
            //this is bcoz to know that something is changed in view
            self.view.layoutIfNeeded()

        
        }
        
    }
    
    
    //to decrease height of uiview after finishing with keyboard
    //TODO: Declare textFieldDidEndEditing here:
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        
        //to add animation
        
        UIView.animate(withDuration: 0.5) {
            
            self.heightConstraint.constant = 50
            //this is bcoz to know that something is changed in view
            self.view.layoutIfNeeded()
            
            
        }

        
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        messageTextfield.endEditing(true)
        
        
        //TODO: Send the message to Firebase and save it in our database
        
        //we did this so that user cant not press send again if he done it already
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //creating database for messages
        let messageDB = FIRDatabase.database().reference().child("Messages")
        
        let messageDictionary = ["sender": FIRAuth.auth()?.currentUser?.email, "messageBody": messageTextfield.text]
        
        //to save messge in DB with unique id
        messageDB.childByAutoId().setValue(messageDictionary){
        
        (error, ref) in
           
            if error != nil {
            
                print(error)
            
            }
            else{
            
                print("message send successfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            
            }
        
        
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    

    
    func retrieveMessages(){
        
        //whenever new messg goes to database
        let messageDB = FIRDatabase.database().reference().child("Messages")
        messageDB.observe(.childAdded, with: { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["messageBody"]!
            let sender = snapshotValue["sender"]!
        
           let message = Message()
            
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            
            //to dynamically resize the body of message
            
            self.configureTableView()
            
            //reload the table view
            self.messageTableView.reloadData()
        
        })
    }
    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
             try FIRAuth.auth()?.signOut()
            
        }
        catch{
            print("There was problem whlie signing out!")
        
        }
        
        //navigate to first screen
        guard (navigationController?.popToRootViewController(animated: true)) != nil
        
        else {
           print("no view controllerto go back")
                return
        }
        
    }
    


}
