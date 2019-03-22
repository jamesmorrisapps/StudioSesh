//
//  VenuePostVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 9/23/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
@IBDesignable

class VenuePostVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var priceLabel: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    var selectedPhoto: UIImage?
    
    var amenitiesArray = ["Lighting Equipment", "Soundboard", "Sound Manager", "Lighting Manager", "PA System", "Great Food", "Great Drinks", "Green Room"]
    var chosenAmenityArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        imageView.layer.cornerRadius = imageView.layer.frame.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPictureImage))
        imageView.addGestureRecognizer(tapGesture)
        
        descriptionLabel.delegate = self
        descriptionLabel.text = "Describe your venue..."
        descriptionLabel.textColor = .lightGray
        
        priceLabel.delegate = self
        priceLabel.text = "Enter your hourly rental rate..."
        priceLabel.textColor = .lightGray
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handlePosts()
    }
    
    func handlePosts() {
        if selectedPhoto != nil {
            shareBtn.backgroundColor = #colorLiteral(red: 0.1059608385, green: 0.7958640456, blue: 0.07565600425, alpha: 1)
            shareBtn.setTitleColor(UIColor.white, for: .normal)
            shareBtn.isEnabled = true
        } else {
            shareBtn.backgroundColor = UIColor.lightGray
            shareBtn.setTitleColor(UIColor.white, for: .normal)
            shareBtn.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (descriptionLabel.text == "Describe your venue...")
        {
            descriptionLabel.text = ""
            descriptionLabel.textColor = .black
        }
       // descriptionLabel.becomeFirstResponder()
        
        if (priceLabel.text == "Enter your hourly rental rate...")
        {
            priceLabel.text = "$"
            priceLabel.textColor = .black
        }
       // priceLabel.becomeFirstResponder()
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (descriptionLabel.text == "")
        {
            descriptionLabel.text = "Describe your venue..."
            descriptionLabel.textColor = .lightGray
        }
        descriptionLabel.resignFirstResponder()
        
        if (priceLabel.text == "$")
        {
            priceLabel.text = "Enter your hourly rental rate..."
            priceLabel.textColor = .lightGray
        }
        priceLabel.resignFirstResponder()
        
        if (priceLabel.text == "")
        {
            priceLabel.text = "Enter your hourly rental rate..."
            priceLabel.textColor = .lightGray
        }
        priceLabel.resignFirstResponder()
        
    }
    
    @objc func handleSelectPictureImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func share(){
        ProgressHUD.show("Posting your content...", interaction: false)
        if let contentToPost = self.selectedPhoto, let imageData = contentToPost.jpegData(compressionQuality: 0.1) {
            
            let contentIdString = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("postedContent").child(contentIdString)
            
            let amenities = chosenAmenityArray.joined(separator: ", ")
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                guard metadata != nil else {
                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                    print("Error occurred.")
                    return
                }
                storageRef.downloadURL { (url, error) in
                    guard (url) != nil else {
                        print("Error occurred.")
                        return
                    }
                    self.sendDataToDatabase(photoUrl: (url?.absoluteString)!)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shouldUpdateFeed"), object: nil, userInfo: [
                        "image" : self.imageView.image!,
                        "description" : self.descriptionLabel.text,
                        "price" : self.priceLabel.text,
                        "perks" : amenities
                        ])
                }
            })
            
        } else {
            ProgressHUD.showError("Whoops! There was an issue. Please try again.")
        }
    }
    
    func sendDataToDatabase(photoUrl: String) {
        let ref = Database.database().reference()
        let postsReference = ref.child("postedContent")
        let newPostId = postsReference.childByAutoId().key
        let newPostReference = postsReference.child(newPostId)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        let currentUserId = currentUser.uid
        let amenities = chosenAmenityArray.joined(separator: ", ")
        newPostReference.setValue((["uid" : currentUserId,"photoUrl" : photoUrl, "description" : descriptionLabel.text!, "price" : priceLabel.text!, "perks" : amenities, "timestamp" : timestamp])) { (error, ref) in
            if error != nil {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                return
            }
            
            API.Feed.REF_FEED.child(API.User.CURRENT_USER!.uid).child(newPostId).setValue(true)

            let venuePostRef = API.VenuePosts.REF_VENUE_POSTS.child(currentUserId).child(newPostId)
            venuePostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                    return
                }
            })
            
            
            ProgressHUD.showSuccess("Posted!")
            self.descriptionLabel.text = ""
            self.priceLabel.text = ""
            self.chosenAmenityArray = []
            self.imageView.image = UIImage(named: "cameraPlaceholder")
            self.selectedPhoto = nil
            self.navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.tabBarController?.selectedIndex = 0
            })
        }
    }
    
    @IBAction func shareBtnWasPressed(_ sender: Any) {
        
        share()
        
//        self.descriptionLabel.text = ""
//        self.priceLabel.text = ""
//        self.perkLabel.text = ""
        self.imageView.image = UIImage(named: "cameraPlaceholder")
        self.selectedPhoto = nil
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.tabBarController?.selectedIndex = 0
        })
    }
    



}

extension VenuePostVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amenitiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueAmenityCell") as! VenueAmenityCell
        
        if chosenAmenityArray.contains(amenitiesArray[indexPath.row]) {
            cell.configureCell(amenity: amenitiesArray[indexPath.row], isSelected: true)
        } else {
            cell.configureCell(amenity: amenitiesArray[indexPath.row], isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! VenueAmenityCell
        if !chosenAmenityArray.contains(cell.amenityLabel.text!) {
            chosenAmenityArray.append(cell.amenityLabel.text!)
        } else {
            chosenAmenityArray = chosenAmenityArray.filter({ $0 != cell.amenityLabel.text!})
        }
    }
}

extension VenuePostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedPhoto = image
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
