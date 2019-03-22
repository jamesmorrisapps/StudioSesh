//
//  SettingsVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 10/24/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

protocol SettingsVCDelegate {
    func updateUserInfo()
}

class SettingsVC: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var changeProfilePhotoBtn: UIButton!
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var bioTextfield: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    var delegate: SettingsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit Profile"
        nameTextfield.delegate = self
        emailTextfield.delegate = self
        bioTextfield.delegate = self
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        API.User.observeCurrentUser { (user) in
            if let profileUrl = URL(string: user.profileImageUrl!) {
                self.profileImageView.sd_setImage(with: profileUrl)
            }
            self.nameTextfield.text = user.username
            self.emailTextfield.text = user.email
            self.bioTextfield.text = user.bio
        }
    }
    
    @IBAction func changeProfilePhotoBtn(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnWasPressed(_ sender: Any) {
        if let profileImg = self.profileImageView.image, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            ProgressHUD.show("Please wait while we work our magic...")
            AuthService.updateUserInfo(username: nameTextfield.text!, email: emailTextfield.text!, bio: bioTextfield.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Your profile has been updated.")
                self.delegate?.updateUserInfo()
            }) {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
            }
        }
        
        if bioTextfield.text != nil {
            Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).child("bio").setValue(["bio" : bioTextfield.text]) { (error, ref) in }
        }
    }
    
    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
            self.present(loginVC, animated: true, completion: nil)
            ProgressHUD.showSuccess("You've been successfully logged out.")
        }) {
            ProgressHUD.showError("Log out failed, please try again.")
        }
    }

}

extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
