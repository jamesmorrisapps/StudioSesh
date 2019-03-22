//
//  MessengerChannelVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/25/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class MessengerChannelVC: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var addSessionBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var sessionsArray = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.revealViewController()?.rearViewRevealWidth = self.view.frame.width - 60
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        API.Sessions.REF_SESSIONS.observe(.value) { (snapshot) in
            API.Sessions.getAllSessions { (returnedSessionsArray) in
                self.sessionsArray = returnedSessionsArray
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchUser() {
        API.User.observeCurrentUser { (user) in
            self.usernameLabel.text = user.username
            if let photoUrlString = user.profileImageUrl {
                let photoUrl = URL(string: photoUrlString)
                self.userProfileImage.sd_setImage(with: photoUrl)
            } else {
                print("Could not load profile image.")
            }
        }
    }
    
    @IBAction func addSessionBtnWasPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "toSessionVC", sender: self.addSessionBtn)
    }
    


}

extension MessengerChannelVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sessionsArray.count == 0 {
            tableView.setEmptyViewSessions(title: "No sessions yet.", message: "Create a new session above!", image: #imageLiteral(resourceName: "chat"))
        }
        else {
            tableView.restore()
        }
        return sessionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
        
        let session = sessionsArray[indexPath.row]
        cell.configureCell(title: session.title, description: session.description, memberCount: session.memberCount)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sessionFeedVC = storyboard?.instantiateViewController(withIdentifier: "SessionFeedVC") as? SessionFeedVC else { return }
        sessionFeedVC.initData(forSession: sessionsArray[indexPath.row])
        present(sessionFeedVC, animated: true, completion: nil)
    }
    
}
