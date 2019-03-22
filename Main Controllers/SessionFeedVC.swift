//
//  SessionFeedVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/29/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class SessionFeedVC: UIViewController {
    
    @IBOutlet weak var constrainToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sessionTitleLabel: UILabel!
    
    @IBOutlet weak var sessionMemberLabel: UILabel!
    
    @IBOutlet weak var sendMessageView: UIView!
    
    @IBOutlet weak var messageTextfield: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var session: Session?
    
    var sessionMessages = [Message]()
    
    func initData(forSession session: Session) {
        self.session = session
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

       //sendMessageView.bindToKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constrainToBottom.constant = -(keyboardFrame?.height)!
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constrainToBottom.constant = 0
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func handleTextField() {
        messageTextfield.addTarget(self, action: #selector(SessionFeedVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let messageText = messageTextfield.text, !messageText.isEmpty {
            sendBtn.setTitleColor(UIColor.green, for: .normal)
            sendBtn.isEnabled = true
            return
        }
        sendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        sendBtn.isEnabled = false
    }
    
    func empty() {
        self.messageTextfield.text = ""
        sendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        sendBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionTitleLabel.text = session?.title
        API.Sessions.getUsernamesFor(session: session!) { (returnedUsernames) in
            self.sessionMemberLabel.text = returnedUsernames.joined(separator: ", ")
        }
        
        API.Sessions.REF_SESSIONS.observe(.value) { (snapshot) in
            API.Sessions.getAllMessagesFor(desiredSession: self.session!, handler: { (returnedSessionMessages) in
                self.sessionMessages = returnedSessionMessages
                self.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if self.sessionMessages.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath.init(row: self.sessionMessages.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            })
        }
    }
    
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if messageTextfield.text != "" {
            messageTextfield.isEnabled = false
            sendBtn.isEnabled = false
            API.Sessions.uploadMessage(withMessage: messageTextfield.text!, forUID: (Auth.auth().currentUser?.uid)!, withSessionKey: session?.key) { (complete) in
                if complete {
                    self.messageTextfield.text = ""
                    self.messageTextfield.isEnabled = true
                    self.sendBtn.isEnabled = true
                    
                    let timestamp = Int(Date().timeIntervalSince1970)
                    var user = ""
                    for mem in self.session!.members {
                        if mem != (Auth.auth().currentUser?.uid)! {
                            user = mem
                            break
                        }
                    }
                    let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(user).childByAutoId().key
                    let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(user).child(newNotificationId)
                    newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "message", "objectId" : self.session!.key, "timestamp" : timestamp])
                }
            }
        }
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}

extension SessionFeedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sessionMessages.count == 0 {
            tableView.setEmptyView(title: "No messages yet.", message: "Start a new message down below!", image: #imageLiteral(resourceName: "message-icon"))
        }
        else {
            tableView.restore()
        }
        return sessionMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionFeedCell", for: indexPath) as! SessionFeedCell
        let message = sessionMessages[indexPath.row]
//        API.Sessions.getUsername(forUID: message.senderId) { (username) in
//            cell.configureCell(profileImage: UIImage(named: "defaultProfileImage-1")!, username: username, content: message.content)
//        }
        API.User.observeUsers(withId: message.senderId) { (user) in
            cell.configureCell(profileImage: user.profileImageUrl!, username: user.username!, content: message.content)
        }
        
        return cell
    }
    
    
}
