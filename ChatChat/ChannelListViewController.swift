//
//  CreateChannelCell.swift
//  ChatChat
//
//  Created by Binh Bui on 08/03/2017.
//  Copyright © 2017 Binh Bui. All rights reserved.
//

import UIKit
import Firebase

// Hold different table view sections.
enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelListViewController: UITableViewController {
    
    /// NOTE: Properties
    
    // Add a property to store the sender’s name
    var senderDisplayName: String?
    // Add a text field which will be used later for adding new Channels
    var newChannelTextField: UITextField?
    // Create an empty array of Channel objects to store channels
    private var channels: [Channel] = []
    // channelRef will be used to store a reference to the list of channels in the database
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    // channelRefHandle will hold a handle to the reference so you can remove it later on.
    private var channelRefHandle: FIRDatabaseHandle?
    
    
    // NOTE: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Channels"
        observeChannels()
    }
    
    // Stop observing database changes when the view controller dies
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    
    /// NOTE: UITableViewDataSource
    
    /*
     Set the number of sections
     1st section - Include a form for adding new channels
     2nd section - Show a list of channels.
    */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Set the number of rows for each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    
    /* 
     Define what goes in each cell
     1st section - Store the text field from the cell in your newChannelTextField property
     2nd section - Set the cell’s text label as your channel name
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
    
    // NOTE: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TO-DO: Not let user select first section
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channels[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }
    
    
    /// NOTE: Actions
    
    @IBAction func createChannel(_ sender: AnyObject) {
        // Check if there is a channel name
        if let name = newChannelTextField?.text {
            // Create a new channel reference with a unique key using childByAutoId()
            let newChannelRef = channelRef.childByAutoId()
            // Create a dictionary to hold the data for this channel.
            let channelItem = [
                "name": name
            ]
            // Set the name on this new channel, which is saved to Firebase automatically
            newChannelRef.setValue(channelItem)
        }
    }
    
    
    /// NOTE: Firebase related methods
    
    private func observeChannels() {
        /* 
         Use the observe method to listen for new
         channels being written to the Firebase DB
         */
        // Calls the completion block every time a new channel is added to your database.
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            // Receive a FIRDataSnapshot (stored in snapshot)
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            // Pull data from snapshot, if successful, create a Channel model and add it to the channels array.
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    /// NOTE: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
}
