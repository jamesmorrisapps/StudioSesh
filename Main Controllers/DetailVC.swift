//
//  DetailVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 10/31/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    
    var postId = ""
    
    var posts = Posts()
    var users = User()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 523
        tableView.rowHeight = UITableView.automaticDimension
        
        print("postId: \(postId)")
        registerCell()
        loadPost()
    }
    
    func registerCell(){
        let nib = UINib(nibName: "VenuePostCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "VenueCell")
    }

    func loadPost() {
        API.Post.observePost(withId: postId) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.posts = post
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUsers(withId: uid) { (user) in
            self.users = user
            completed()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentSegue" {
            let commentVC = segue.destination as! CommentVC
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Detail_ProfileUserSegue" {
            let profileVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Detail_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagVC
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }

}

extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if posts.description == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
            (cell as! PostCell).post = posts
            (cell as! PostCell).user = users
            (cell as! PostCell).delegate = self
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath)
            (cell as! VenuePostCell).post = posts
            (cell as! VenuePostCell).user = users
            (cell as! VenuePostCell).delegate = self as? VenueCellDelegate
    }
        return cell
    }
}

extension DetailVC: PostCellDelegate {
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Detail_HashtagSegue", sender: tag)
    }
    
    func performSegue(_ id: String, sender: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Detail_CommentSegue", sender: sender)
        }
    }
    
    func goToProfileUserVC(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Detail_ProfileUserSegue", sender: userId)
        }
    }
}
