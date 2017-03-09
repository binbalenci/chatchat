//
//  CreateChannelCell.swift
//  ChatChat
//
//  Created by Binh Bui on 08/03/2017.
//  Copyright © 2017 Binh Bui. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

final class ChatViewController: JSQMessagesViewController {
    
    /// NOTE: Properties
    
    var channelRef: FIRDatabaseReference?
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    
    /// NOTE: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the senderId based on the logged in Firebase user.
        self.senderId = FIRAuth.auth()?.currentUser?.uid
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// NOTE: Collection view data source (and related) methods
    
    
    /// NOTE: Firebase related methods
    
    
    /// NOTE: UI and User Interaction
    
    
    /// NOTE: UITextViewDelegate methods
    
}
