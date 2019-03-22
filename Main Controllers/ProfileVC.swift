//
//  ProfileVC.swift
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

class ProfileVC: UIViewController {

    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var profileView: ProfileReusableView!
    
    var user: User!
    var posts: [Posts] = []
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self

        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        fetchUser()
        fetchUserPosts()
    }
    
//    func fetchUser(uid: String, completed: @escaping () -> Void) {
//        API.User.observeUsers(withId: uid) { (user) in
//            self.users.append(user)
//            completed()
//        }
//    }
    
    func fetchUser() {
        API.User.observeCurrentUser { (user) in
            self.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                self.user = user
                self.navigationItem.title = user.username
                self.profileCollectionView.reloadData()
            })
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    func fetchUserPosts() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        API.UserPosts.REF_USER_POSTS.child(currentUser.uid).observe(.childAdded) { (snapshotUserPost) in
            API.Post.observePost(withId: snapshotUserPost.key, completion: { (post) in
                self.posts.append(post)
                self.profileCollectionView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_SettingSegue" {
            let settingsVC = segue.destination as! SettingsVC
            settingsVC.delegate = self
        }
        
        if segue.identifier == "Profile_DetailSegue" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
        
        if segue.identifier == "toReviewsVC" {
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

    @IBAction func shareBtnWasPressed(_ sender: Any) {
        if user.persona == "Artist" {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyboard.instantiateViewController(withIdentifier: "shareVC")
        self.navigationController?.pushViewController(shareVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let venuePostVC = storyboard.instantiateViewController(withIdentifier: "venuePostVC")
            self.navigationController?.pushViewController(venuePostVC, animated: true)
        }
    }
    
    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
                goToSignIn()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func goToSignIn(){
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        self.present(initial!, animated: true, completion: nil)
    }
    
}

extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if posts.count == 0 {
            profileCollectionView.setEmptyViewProfile(title: "No posts yet.", message: "Tap share to share some content!")
        }
        else {
            profileCollectionView.restore()
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let profileReusableView = profileCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "profileReusableView", for: indexPath) as! ProfileReusableView

        if let user = self.user {
            profileReusableView.user = user
            profileReusableView.delegate2 = self
            profileReusableView.delegate3 = self
            profileReusableView.delegate4 = self
            profileReusableView.delegate5 = self
        }
        return profileReusableView
    }
    
}

extension ProfileVC: ProfileReusableViewDelegateSwtichSettingsVC {
    func goToSettingsVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
}

extension ProfileVC:ProfileReusableViewDelegateSwitchReviewsVC {
    func goToReviewsVC(userId: String) {
        performSegue(withIdentifier: "toReviewsVC", sender: userId)
    }
}

extension ProfileVC: SettingsVCDelegate {
    func updateUserInfo() {
        self.fetchUser()
    }
}

extension ProfileVC: PhotoCellDelegate {
    func goToDetailVC(postId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Profile_DetailSegue", sender: postId)
        }
    }
}

extension ProfileVC: ProfileReusableViewDelegateToFollowers {
    func goToFollowers(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toFollowers", sender: userId)
        }
    }
}

extension ProfileVC: ProfileReusableViewDelegateToFollowing {
    func goToFollowing(userId: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toFollowing", sender: userId)
        }
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: profileCollectionView.frame.size.width / 3 - 1, height: profileCollectionView.frame.size.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ProfileVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
        
        if tabBarIndex == 4 {
            self.profileCollectionView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
}
