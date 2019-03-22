//
//  Search+HistoryVC.swift
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


class Search_HistoryVC: UIViewController {
    
    var posts = [Posts]()
    var users = [User]()
    var priceToSend: String?
    
    
    @IBOutlet weak var searchTableView: UITableView!
    
   
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.estimatedRowHeight = 523
        searchTableView.rowHeight = UITableView.automaticDimension
        
        self.tabBarController?.delegate = self

        searchTableView.dataSource = self
        searchTableView.delegate = self
        
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        searchTableView.addSubview(refreshControl)
        
        registerCell()
        loadPosts()
    }
    
    func registerCell(){
        let nib = UINib(nibName: "VenuePostCell", bundle: nil)
        searchTableView.register(nib, forCellReuseIdentifier: "VenueCell")
    }
    
    @objc func refresh() {
        self.posts.removeAll()
        self.users.removeAll()
        loadPosts()
    }
    
    func loadPosts() {
        
        API.Feed.observeFeed(withId: API.User.CURRENT_USER!.uid) { (post) in
            guard !self.posts.contains(where: {
                $0.id! == post.id!
            })else{
                for index in 0..<self.posts.count {
                    if self.posts[index].id! == post.id! {
                        self.posts[index] = post
                        break
                    }
                }
                return
            }
            guard let postUid = post.uid else {
                return
            }
            API.User.observeUsers(withId: postUid) { (user) in
                self.posts.insert(post, at: 0)
                self.users.insert(user, at: 0)
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.activityIndicatorView.stopAnimating()
            self.searchTableView.reloadData()
        }
        
        API.Feed.observeVenuePosts { (posts) in
            let group = DispatchGroup()
            for post in posts {
                guard !self.posts.contains(where: {
                    $0.id! == post.id!
                })else{
                    for index in 0..<self.posts.count {
                        if self.posts[index].id! == post.id! {
                            self.posts[index] = post
                            break
                        }
                    }
                    continue
                }
                guard let postUid = post.uid else {
                    return
                }
                group.enter()
                API.User.observeUsers(withId: postUid) { (user) in
                    self.posts.insert(post, at: 0)
                    self.users.insert(user, at: 0)
                    group.leave()
                }
            }
            group.notify(queue: .main, execute: {
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.timestamp! > p2.timestamp!
                })
                let tmp = self.users
                self.users = []
                for index in 0..<self.posts.count {
                    guard let id = self.posts[index].uid else{
                        continue
                    }
                    for user in tmp {
                        guard let uid = user.id else{
                            continue
                        }
                        guard uid == id else{
                            continue
                        }
                        self.users.append(user)
                        break
                    }
                }
                self.searchTableView.reloadData()
            })
            
        }
        
        API.Feed.observeFeedRemoved(withId: API.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id }
            self.users = self.users.filter { $0.id != post.uid }
            self.searchTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentVC = segue.destination as! CommentVC
            let postId = sender as! String
            commentVC.postId = postId 
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserVC
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagVC
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }

}

extension Search_HistoryVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if posts.count == 0 {
            searchTableView.setEmptyView(title: "No posts yet.", message: "Add a new posts from your profile!", image: #imageLiteral(resourceName: "post-icon"))
        }
        else {
            searchTableView.restore()
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        
        if post.description == nil {
            cell = searchTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
            (cell as! PostCell).post = post
            (cell as! PostCell).user = user
            (cell as! PostCell).delegate = self
        }else{
            cell = searchTableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath)
            (cell as! VenuePostCell).post = post
            (cell as! VenuePostCell).user = user
            (cell as! VenuePostCell).delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookingPreviewVC = storyboard?.instantiateViewController(withIdentifier: "BookingPreviewVC") as? BookingPreviewVC else { return }
        if posts[indexPath.row].description != nil {
            priceToSend = posts[indexPath.row].price
            bookingPreviewVC.initData(forVenue: users[indexPath.row], forPost: posts[indexPath.row], forPrice: priceToSend!)
            navigationController?.present(bookingPreviewVC, animated: true, completion: nil)
        }
//        Date()
//        let formatter = DateFormatter()
//         formatter.dateFormat = "EEE, MMM, dd, yyyy h:mm:ss "
//        let dateStr = formatter.string(from: <#T##Date#>)
    }

}

extension Search_HistoryVC:PostCellDelegate {
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Home_HashtagSegue", sender: tag)
    }
    
    func performSegue(_ id: String, sender: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: id, sender: sender)
        }
    }
    
}

extension Search_HistoryVC:VenueCellDelegate {
    func performVenueSegue(_ id: String, sender: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: id, sender: sender)
        }
    }
    
    func goToProfileUserVC(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
        }
    }
    
}

extension Search_HistoryVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
        
        if tabBarIndex == 0 {
            self.searchTableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
}
