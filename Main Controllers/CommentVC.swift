//
//  CommentVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/8/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class CommentVC: UIViewController {

    @IBOutlet weak var constrainToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var postId: String!
    
    var comments = [Comment]()
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Comments"
        
        commentTableView.estimatedRowHeight = 85
        commentTableView.rowHeight = UITableView.automaticDimension
        
        commentTableView.dataSource = self

       empty()
        handleTextField()
       loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func loadComments() {
        
        API.Post_Comment.REF_POST_COMMENTS.child(self.postId).observe(.childAdded) { (snapshotComment) in
            
            API.Comment.observeComments(withPostId: snapshotComment.key, completion: { (comment) in
                self.fetchUser(uid: comment.uid!, completed: {
                    DispatchQueue.main.async {
                        self.comments.append(comment)
                        self.commentTableView.reloadData()
            }
        })
    })
  }
}
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        
        API.User.observeUsers(withId: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }
    
    
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(CommentVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendBtn.setTitleColor(UIColor.green, for: .normal)
            sendBtn.isEnabled = true
            return
        }
        sendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        sendBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func sendBtnWasPressed(_ sender: Any) {
        
        let commentsReference = API.Comment.REF_COMMENTS
        let newCommentId = commentsReference.childByAutoId().key
        let newCommentReference = commentsReference.child(newCommentId)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        newCommentReference.setValue((["uid" : currentUserId, "commentText" : commentTextField.text!])) { (error, ref) in
            if error != nil {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                return
            }
            
            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            
            for var word in words {
                if word.hasPrefix("#") {
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                    let newHashtagRef = API.Hashtag.REF_HASHTAGS.child(word.lowercased())
                    newHashtagRef.updateChildValues([self.postId: true])
                }
            }
            
            let timestamp = Int(Date().timeIntervalSince1970)
            let ref = Database.database().reference()
            let postsReference = ref.child("postedContent")
            let newPostId = postsReference.childByAutoId().key
            API.Follow.REF_FOLLOWERS.child(API.User.CURRENT_USER!.uid).observe(.value, with: { (snapshot) in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    API.Post_Comment.REF_POST_COMMENTS.child(child.key).updateChildValues(["\(newPostId)" : true])
                    let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(child.key).childByAutoId().key
                    let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(child.key).child(newNotificationId)
                    newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "comment", "objectId" : self.postId, "timestamp" : timestamp])
                })
            })
            
            let postCommentRef = API.Post_Comment.REF_POST_COMMENTS.child(self.postId).child(newCommentId)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                    return
                }
            })
            self.empty()
            self.view.endEditing(true)
        }
    }
    
    func empty() {
        self.commentTextField.text = ""
        sendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        sendBtn.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Comment_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Comment_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagVC
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }
    

}

extension CommentVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if comments.count == 0 {
            commentTableView.setEmptyView(title: "No comments yet.", message: "Add a new comment down below!", image: #imageLiteral(resourceName: "comment-icon"))
        }
        else {
            commentTableView.restore()
        }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentVC: CommentCellDelegate {
    
    func goToProfileUserVC(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
        }
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Comment_HashtagSegue", sender: tag)
    }
}
