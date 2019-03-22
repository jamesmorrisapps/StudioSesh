//
//  FollowersVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/27/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class FollowersVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    
    var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()
    }
    
    func loadUsers() {
        observeUsers { (user) in
            self.isFollower(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                
                if user.id != self.userId {
                    
                    if user.isFollowing == true {
                        self.users.append(user)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    
    func isFollower(userId: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollower(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileVC.userId = userId
            profileVC.delegate = self
        }
    }
    
    func observeUsers(completion: @escaping (User) -> Void) {
        API.User.REF_USERS.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}

extension FollowersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if users.count == 0 {
            tableView.setEmptyView(title: "No users yet.", message: "StudioSesh's users will appear here for you to search for.", image: #imageLiteral(resourceName: "users-icon"))
        }
        else {
            tableView.restore()
        }
        print(users.count)
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleCell", for: indexPath) as! PeopleCell
        
        let user = users[indexPath.row]
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension FollowersVC: PeopleCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ProfileSegue", sender: userId)
    }
}

extension FollowersVC: ProfileReusableViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in self.users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
