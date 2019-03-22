//
//  SearchVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 9/6/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var searchBar = UISearchBar()
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Type 'artist', 'venue', or username..."
        searchBar.frame.size.width = view.frame.size.width - 60
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        doSearch()
    }

    func doSearch() {
        if searchBar.text?.lowercased() == "artist" || searchBar.text?.lowercased() == "artists" {
            self.users.removeAll()
            self.tableView.reloadData()
            API.User.queryUserByPersona(withPersona: "Artist") { (user) in
                self.isFollowing(userId: user.id!, completed: { (value) in
                    user.isFollowing = value
                    if user.id != API.User.CURRENT_USER?.uid {
                        self.users.append(user)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
        else if searchBar.text?.lowercased() == "venue" || searchBar.text?.lowercased() == "venues" {
            self.users.removeAll()
            self.tableView.reloadData()
            API.User.queryUserByPersona(withPersona: "Venue") { (user) in
                self.isFollowing(userId: user.id!, completed: { (value) in
                    user.isFollowing = value
                    if user.id != API.User.CURRENT_USER?.uid {
                        self.users.append(user)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
        else {
            if let searchText = searchBar.text?.lowercased() {
                self.users.removeAll()
                self.tableView.reloadData()
                API.User.queryUser(withText: searchText) { (user) in
                    self.isFollowing(userId: user.id!, completed: { (value) in
                        user.isFollowing = value
                        if user.id != API.User.CURRENT_USER?.uid {
                            self.users.append(user)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileVC.userId = userId
            profileVC.delegate = self
        }
    }
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if users.count == 0 {
            tableView.setEmptyView(title: "No users yet.", message: "StudioSesh's users will appear here for you to follow.", image: #imageLiteral(resourceName: "users-icon"))
        }
        else {
            tableView.restore()
        }
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

extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
    
    
}

extension SearchVC: PeopleCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Search_ProfileSegue", sender: userId)
    }
}

extension SearchVC: ProfileReusableViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in self.users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
