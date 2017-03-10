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
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    private lazy var usersTypingQuery: FIRDatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    /// NOTE: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the senderId based on the logged in Firebase user.
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeTyping()
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        // Retrieve the message
        let message = messages[indexPath.item]
        // If the message was sent by the local user, return the outgoing image view
        if message.senderId == senderId {
            return outgoingBubbleImageView
        // Otherwise, return the incoming image view
        } else {
            return incomingBubbleImageView
        }
    }
    
    // Remove the avatar image
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    
    /// NOTE: Firebase related methods
    
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        // Creating a query that limits the synchronization to the last 25 messages
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // Extract the messageData from the snapshot
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text)
                
                // Inform JSQMessagesViewController that a message has been received
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        // Observe for changes using .value; this will call the completion block anytime it changes
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            // You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    // Create a Firebase reference that tracks whether the local user is typing
    private lazy var userIsTypingRef: FIRDatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId)
    // Store whether the local user is typing in a private property
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // Use a computed property to update localTyping and userIsTypingRef each time it’s changed
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    /// NOTE: UI and User Interaction
    
    /* 
     The messages displayed in the collection view are images with text overlaid
     Outgoing messages are displayed to the right and incoming messages on the left.
     */
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        // Set outgoing message overlay to be blue
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(netHex: 0xF5A623))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        // Set incoming message overlay to be light gray
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // Using childByAutoId() to create a child reference with a unique key
        let itemRef = messageRef.childByAutoId()
        // Create a dictionary to represent the message.
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        // Save the value at the new child location
        itemRef.setValue(messageItem)
        
        // Play the canonical “message sent” sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // Reset the input toolbar to empty
        finishSendingMessage()
        
        isTyping = false
    }
    
    
    /// NOTE: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
}
