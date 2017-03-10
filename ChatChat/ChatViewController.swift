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
    var messages = [JSQMessage]()
    
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
    
    /*
     The first is much like collectionView(_:cellForItemAtIndexPath:), but for message data
     The second is the standard way to return the number of messsages
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    /// NOTE: Firebase related methods
    
    
    /// NOTE: UI and User Interaction
    
    
    /// NOTE: UITextViewDelegate methods
    
}
