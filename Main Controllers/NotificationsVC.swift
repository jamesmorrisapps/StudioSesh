//
//  NotificationsVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/25/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [Notification]() {
        didSet{
            self.notifications.sort(by: {
                $0.timestamp! > $1.timestamp!
            })
            let tmp = self.users
            self.users = []
            for noti in notifications {
                for user in tmp {
                    if user.id! == noti.from!{
                        self.users.append(user)
                        break
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotifications()
    }

    func loadNotifications() {
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        API.Notification.observeNotifications(withId: currentUser.uid) { (notification) in
            guard let uid = notification.from else {
                return
            }
            API.User.observeUsers(withId: uid) { (user) in
                self.users.insert(user, at: 0)
                self.notifications.insert(notification, at: 0)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Notifications_DetailSegue" {
            let detailVC = segue.destination as! DetailVC
            let notification = sender as! Notification
            detailVC.postId = notification.objectId!
        }
        
        if segue.identifier == "Notifications_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserVC
            let notification = sender as! Notification
            profileVC.userId = notification.from!
        }
    }

}

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if notifications.count == 0 {
            tableView.setEmptyView(title: "No notifications yet.", message: "Your notifications will appear here.", image: #imageLiteral(resourceName: "notification-icon"))
        }
        else {
            tableView.restore()
        }
        return notifications.count
        print(notifications.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notification = notification
        cell.user = user
        cell.delegate = self
        
        return cell
    }
}

extension NotificationsVC: NotificationsCellDelegate {
    func goToDetailVC(notification: Notification) {
        if notification.type == "feed" {
            performSegue(withIdentifier: "Notifications_DetailSegue", sender: notification)
        } else if notification.type == "like" {
            performSegue(withIdentifier: "Notifications_ProfileSegue", sender: notification)
        } else if notification.type == "comment" {
            performSegue(withIdentifier: "Notifications_DetailSegue", sender: notification)
        } else if notification.type == "follow" {
            performSegue(withIdentifier: "Notifications_ProfileSegue", sender: notification)
        }
        
    }
    
}
