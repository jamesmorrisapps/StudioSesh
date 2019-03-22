//
//  DiscoverPicVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 10/6/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class DiscoverPicVC: UIViewController {
    
    @IBOutlet weak var exitButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [Posts] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadTopPosts()
    }
    
    func loadTopPosts() {
        //ProgressHUD.show("Loading Popular Posts...", interaction: false)
        self.posts.removeAll()
        self.collectionView.reloadData()
        API.Post.observeTopPosts { (post) in
            self.posts.append(post)
            self.collectionView.reloadData()
            ProgressHUD.dismiss()
        }
    }

    @IBAction func exitButtonWasPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_DetailSegue" {
            let detailVC = segue.destination as! DetailVC
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}

extension DiscoverPicVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if posts.count == 0 {
            collectionView.setEmptyView(title: "No posts yet.", message: "StudioSesh's trending posts will appear here for you to check out.", image: #imageLiteral(resourceName: "post-icon"))
        }
        else {
            collectionView.restore()
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        
        return cell
    }
}

extension DiscoverPicVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DiscoverPicVC: PhotoCellDelegate {
    
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
}
