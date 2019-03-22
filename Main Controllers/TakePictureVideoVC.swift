//
//  TakePictureVideoVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/2/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import UserNotifications
@IBDesignable

class TakePictureVideoVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var pictureImage: UIImageView!
    
    @IBOutlet weak var pictureCaption: UITextView!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    var selectedPhoto: UIImage?
    
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pictureImage.layer.cornerRadius = pictureImage.layer.frame.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPictureImage))
        pictureImage.addGestureRecognizer(tapGesture)
        
        pictureCaption.delegate = self
        pictureCaption.text = "Write a caption..."
        pictureCaption.textColor = .lightGray
        
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
        if (pictureCaption.text == "Write a caption...")
        {
            pictureCaption.text = ""
            pictureCaption.textColor = .black
        }
        pictureCaption.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (pictureCaption.text == "")
        {
            pictureCaption.text = "Write a caption..."
            pictureCaption.textColor = .lightGray
        }
        pictureCaption.resignFirstResponder()
    }
    
    @objc func handleSelectPictureImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func shareBtnWasPressed(_ sender: Any) {
        ProgressHUD.show("Posting your content...", interaction: false)
        if let contentToPost = self.pictureImage.image, let imageData = contentToPost.jpegData(compressionQuality: 0.1) {
            
            let ratio = contentToPost.size.width / contentToPost.size.height
            
            uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio: ratio, caption: pictureCaption.text!, onSuccess: {
                self.pictureCaption.text = ""
                self.pictureImage.image = UIImage(named: "cameraPlaceholder")
                self.selectedPhoto = nil
                self.navigationController?.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.tabBarController?.selectedIndex = 0
                })
            })
            
        } else {
                ProgressHUD.showError("Please choose a photo first.")
            }
        }
    
    func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping() -> Void) {
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl) { (videoUrl) in
                self.uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    self.sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
                })
            }
            //self.sendDataToDatabase(photoUrl: String, ratio: CGFloat)
        } else {
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    
    func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping(_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("postedContent").child(videoIdString)
        
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
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
                
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    onSuccess(videoUrl)
                }
            }
        }
    }
    
    func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping(_ imageUrl: String) -> Void) {
        let imageIdString = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("postedContent").child(imageIdString)
        
        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
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
                
                if let photoUrl = metadata?.downloadURL()?.absoluteString {
                    onSuccess(photoUrl)
                }
            }
        })
    }
    
    func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping() -> Void) {
        let ref = Database.database().reference()
        let postsReference = ref.child("postedContent")
        let newPostId = postsReference.childByAutoId().key
        let newPostReference = postsReference.child(newPostId)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashtagRef = API.Hashtag.REF_HASHTAGS.child(word.lowercased())
                newHashtagRef.updateChildValues([newPostId: true])
            }
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var dict = ["uid" : currentUserId,"photoUrl" : photoUrl, "caption" : caption, "likeCount" : 0, "ratio" : ratio, "timestamp" : timestamp] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        newPostReference.setValue((dict)) { (error, ref) in
            if error != nil {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                return
            }
            
            API.Feed.REF_FEED.child(API.User.CURRENT_USER!.uid).child(newPostId).setValue(true)
            
            API.Follow.REF_FOLLOWERS.child(API.User.CURRENT_USER!.uid).observe(.value, with: { (snapshot) in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    API.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)" : true])
                    let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(child.key).childByAutoId().key
                    let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(child.key).child(newNotificationId)
                    newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "feed", "objectId" : newPostId, "timestamp" : timestamp])
                    
//                    let content = UNMutableNotificationContent()
//                    content.title = "Title"
//                    content.body = "Body"
//                    content.sound = UNNotificationSound.default
//
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//                    let request = UNNotificationRequest(identifier: "post", content: content, trigger: trigger)
//
//                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                })
            })
            
            let userPostRef = API.UserPosts.REF_USER_POSTS.child(currentUserId).child(newPostId)
            userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                    return
                }
            })
            
            
            ProgressHUD.showSuccess("Posted!")
            self.pictureCaption.text = ""
            self.pictureImage.image = UIImage(named: "cameraPlaceholder")
            self.selectedPhoto = nil
            self.navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.tabBarController?.selectedIndex = 0
            })
        }
    }
    
    func goToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! Search_HistoryVC
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Filter_Segue" {
            let filterVC = segue.destination as! FilterVC
            filterVC.selectedImage = self.selectedPhoto
            filterVC.delegate = self
        }
    }
    
}

extension TakePictureVideoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let thumbnailImage = self.thumbnailForFileUrl(videoUrl) {
                selectedPhoto = thumbnailImage
                pictureImage.image = thumbnailImage
                self.videoUrl = videoUrl
            }
            dismiss(animated: true, completion: nil)
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedPhoto = image
            pictureImage.image = image
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "Filter_Segue", sender: nil)
            }
        }
    }
    
    func thumbnailForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 10), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        return nil
    }
}

extension TakePictureVideoVC: FilterVCDelegate {
    func updatePhoto(image: UIImage) {
        self.pictureImage.image = image
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
