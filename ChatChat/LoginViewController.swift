//
//  CreateChannelCell.swift
//  ChatChat
//
//  Created by Binh Bui on 08/03/2017.
//  Copyright © 2017 Binh Bui. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    /// NOTE: Properties
    
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var stateMessage: UILabel!
    
    /// NOTE: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
        //            if user != nil {
        //                self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        //            }
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func loginBtnPressed(_ sender: AnyObject) {
        
        if(checkTextFieldEmpty(textField: loginEmailField.text) || checkTextFieldEmpty(textField: loginPasswordField.text)) {
            stateMessage.text = "Please check your username/password and try again."
        } else {
            FIRAuth.auth()!.signIn(withEmail: self.loginEmailField.text!, password: self.loginPasswordField.text!) { (user, error) in
                // Check to see if there is an authentication error
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                // Trigger the segue to move to the ChannelListViewController
                self.performSegue(withIdentifier: "LoginToChat", sender: nil)
            }
        }
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
                                      message: "",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                                   password: passwordField.text!) { user, error in
                                                                    if error == nil {
                                                                        self.stateMessage.text = "User successfully registered, please log in to chat!"
                                                                    } else {
                                                                        self.stateMessage.text = error?.localizedDescription
                                                                    }
                                        }
        }
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// NOTE: Notifications
    
    // Move the bottomLayout up when keyboard shows
    func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardEndFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        bottomLayoutGuideConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        backgroundImg.alpha = 0.5
    }
    
    // Move it back down
    func keyboardWillHideNotification(_ notification: Notification) {
        bottomLayoutGuideConstraint.constant = 91
        backgroundImg.alpha = 1
    }
    
    
    /// NOTE: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Retrieve the destination view controller from segue and cast it to a UINavigationController
        let navVc = segue.destination as! UINavigationController
        // Cast the first view controller of the UINavigationController to a ChannelListViewController
        let channelVc = navVc.viewControllers.first as! ChannelListViewController
        
        // Set the senderDisplayName in the ChannelListViewController to the name provided in the nameField by the user.
        channelVc.senderDisplayName = loginEmailField?.text
    }
    
    /// NOTE: Supporting Functions
    
    // Check if the text field is empty
    func checkTextFieldEmpty(textField: String?) -> Bool{
        if(textField == "" || textField == nil) {
            return true
        }
        
        return false
    }
}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginEmailField {
            loginPasswordField.becomeFirstResponder()
        }
        if textField == loginPasswordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
