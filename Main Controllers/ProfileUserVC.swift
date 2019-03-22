//
//  ProfileUserVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 10/9/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class ProfileUserVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: ProfileReusableViewDelegate?
    
    var posts: [Posts] = []
    var user: User!
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchUserPosts()
    }
    
    func fetchUser() {
        API.User.observeUsers(withId: userId) { (user) in
            self.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
            })
        }
    }
    
    func fetchUserPosts() {
        API.UserPosts.fetchUserPosts(userId: userId) { (key) in
            API.Post.observePost(withId: key, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileUser_DetailSegue" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
        
        if segue.identifier == "userToReviewsVC" {
            let reviewsVC = segue.destination as! ReviewsVC
            let userId = sender as! String
            reviewsVC.userId = userId
        }
        
        if segue.identifier == "toFollowers" {
            let followersVC = segue.destination as! FollowersVC
            let userId = sender as! String
            followersVC.userId = userId
        }
        
        if segue.identifier == "toFollowing" {
            let followingVC = segue.destination as! FollowingVC
            let userId = sender as! String
            followingVC.userId = userId
        }
    }


}

extension ProfileUserVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if posts.count == 0 {
            collectionView.setEmptyViewProfile(title: "No posts yet.", message: "Posts from this user will appear here.")
        }
        else {
            collectionView.restore()
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let profileReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "profileReusableView", for: indexPath) as! ProfileReusableView
        if let user = self.user {
            profileReusableView.user = user
            profileReusableView.delegate = self.delegate
            profileReusableView.delegate2 = self
            profileReusableView.delegate3 = self
            profileReusableView.delegate4 = self
            profileReusableView.delegate5 = self
        }
        return profileReusableView
    }
    
}

extension ProfileUserVC: ProfileReusableViewDelegateSwtichSettingsVC {
    func goToSettingsVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
}

extension ProfileUserVC: ProfileReusableViewDelegateSwitchReviewsVC {
    func goToReviewsVC(userId: String) {
        performSegue(withIdentifier: "userToReviewsVC", sender: userId)
    }
}

extension ProfileUserVC: PhotoCellDelegate {
    func goToDetailVC(postId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ProfileUser_DetailSegue", sender: postId)
        }
    }
}

extension ProfileUserVC: ProfileReusableViewDelegateToFollowers {
    func goToFollowers(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toFollowers", sender: userId)
        }
    }
}

extension ProfileUserVC: ProfileReusableViewDelegateToFollowing {
    func goToFollowing(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toFollowing", sender: userId)
        }
    }
}

extension ProfileUserVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
}
