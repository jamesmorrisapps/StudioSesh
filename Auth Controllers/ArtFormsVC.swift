//
//  ArtFormsVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/31/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
@IBDesignable

class ArtFormsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var artFormsCollectionView: UICollectionView!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    var artformId: String!
    
    var selected = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func doneBtnWasPressed(_ sender: Any) {
        let selectedList = selected.joined(separator: ", ")
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).child("artforms").setValue(["artforms" : selectedList]) { (error, ref) in
            
        }
//        let artformsReference = API.Artforms.REF_ARTFORMS
//        let newArtformId = artformsReference.childByAutoId().key
//        let newArtformReference = artformsReference.child(newArtformId)
//        guard let currentUser = Auth.auth().currentUser else {
//            return
//        }
//        let currentUserId = currentUser.uid
//        newArtformReference.setValue((["uid" : currentUserId, "artforms" : selectedList])) { (error, ref) in
//            if error != nil {
//                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
//                return
//            }
//            let userArtformRef = API.User_Artform.REF_USER_ARTFORM.child(self.artformId).child(newArtformId)
//            userArtformRef.setValue(true, withCompletionBlock: { (error, ref) in
//                if error != nil {
//                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
//                    return
//                }
//            })
//        }
        print(selectedList)
        goToMain()
    }
    
    func goToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        // let searchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! Search_HistoryVC
        self.navigationController?.pushViewController(initial!, animated: true)
    }
    

    let images = [UIImage(named: "fashion.png"), UIImage(named: "painting.png"), UIImage(named: "animation.png"), UIImage(named: "music.png"), UIImage(named: "ceramics.png"), UIImage(named: "illustration.png"), UIImage(named: "film.png"), UIImage(named: "dance.png"), UIImage(named: "design.png"), UIImage(named: "photography.png"), UIImage(named: "sculpture.png"), UIImage(named: "acting.png"), UIImage(named: "glass.png"), UIImage(named: "literature.png"), UIImage(named: "culinary.png"), UIImage(named: "jewelry.png")]
    
    let labels = ["Fashion", "Painting", "Animation", "Music", "Ceramics", "Illustration", "Film", "Dance", "Design", "Photography", "Sculpture", "Acting", "Glass", "Literature", "Culinary", "Jewelry"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let artFormCell = artFormsCollectionView.dequeueReusableCell(withReuseIdentifier: "artFormCell", for: indexPath) as! ArtFormCollectionViewCell
        artFormCell.artFormImage.image = images[indexPath.item]
        artFormCell.artFormLabel.text = labels[indexPath.item]
        return artFormCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 40 ) / 4, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellTitle = String(labels[indexPath.item])
        let cell = collectionView.cellForItem(at: indexPath) as! ArtFormCollectionViewCell
        cell.artFormSelectedImage.isHidden = !cell.artFormSelectedImage.isHidden
        selected.append(cellTitle)
    }


}

