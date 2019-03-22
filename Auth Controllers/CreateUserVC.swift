//
//  CreateUserVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/29/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import FBSDKCoreKit
import FBSDKLoginKit
@IBDesignable

class CreateUserVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var imageLabel: UILabel!
    
    @IBOutlet weak var fullNameLabel: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    @IBOutlet weak var personaLabel: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var toLoginBtn: UIButton!
    
    var selectedProfileImage: UIImage?
    
    let personas = ["Artist", "Venue"]
    
    var selectedPersona: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedProfileImage)
        
        signUpBtn.layer.cornerRadius = 5
        signUpBtn.isEnabled = false

        profileImage.layer.cornerRadius = profileImage.layer.frame.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateUserVC.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateUserVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
        createPicker()
        createToolbar()
    }
    
    func createPicker() {
        
        let picker = UIPickerView()
        picker.delegate = self
        
        personaLabel.inputView = picker
        
        picker.backgroundColor = .white
    }
    
    func createToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        toolbar.barTintColor = #colorLiteral(red: 0.1059608385, green: 0.7958640456, blue: 0.07565600425, alpha: 1)
        toolbar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreateUserVC.keyboardDismiss))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        personaLabel.inputAccessoryView = toolbar
    }
    
    
    func handleTextField() {
        fullNameLabel.addTarget(self, action: #selector(CreateUserVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        emailLabel.addTarget(self, action: #selector(CreateUserVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordLabel.addTarget(self, action: #selector(CreateUserVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let username = fullNameLabel.text, !username.isEmpty, let email = emailLabel.text, !email.isEmpty, let password = passwordLabel.text, !password.isEmpty, let persona = personaLabel.text, !persona.isEmpty else {
            signUpBtn.setTitleColor(UIColor.lightGray, for: .normal)
            signUpBtn.isEnabled = false
            return
        }
        signUpBtn.setTitleColor(UIColor.white, for: .normal)
        signUpBtn.isEnabled = true
    }
    
    @objc func keyboardDismiss() {
        textFieldDidChange()
        view.endEditing(true)
    }
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func signUpBtnWasPressed(_ sender: Any) {
        let index = emailLabel.text!.firstIndex(of: "@") ?? emailLabel.text!.endIndex
        let usernameFromEmail = emailLabel.text![..<index]
        let username = fullNameLabel.text
        let email = emailLabel.text
        let password = passwordLabel.text
        let persona = personaLabel.text
        let artforms = [String]()
        let bio = ""
        
        if (emailLabel.text?.isEmpty)! || (passwordLabel.text?.isEmpty)! {
            // Display error message and shake create account button
            signUpBtn.wiggle()
            
        } else if (selectedProfileImage == nil) {
            imageLabel.textColor = #colorLiteral(red: 1, green: 0.1505128889, blue: 0.1387367761, alpha: 1)
            signUpBtn.wiggle()
            imageLabel.text = "Please choose a profile image."
        } else {
            ProgressHUD.show("Signing you up...", interaction: false)
            if let profileImg = self.selectedProfileImage, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
                AuthService.signUp(username: username!, usernameFromEmail: String(usernameFromEmail), email: email!, password: password!, persona: persona!, bio: bio, imageData: imageData, onSuccess: {
                    ProgressHUD.showSuccess("Bingo! You're in. Welcome to StudioSesh!")
                    if self.personaLabel.text == "Artist" {
                    DispatchQueue.main.async {
                        self.goToArtForms()
                    }
                    } else {
                        DispatchQueue.main.async {
                            self.goToVenues()
                        }
                    }
                }) {
                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                    self.signUpBtn.wiggle()
                }
        }
    }
    }
    
    @IBAction func toLoginBtnWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        // let searchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! Search_HistoryVC
        self.navigationController?.pushViewController(initial!, animated: true)
    }
    
    func goToArtForms() {
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let artFormVC = storyboard.instantiateViewController(withIdentifier: "artFormVC") as! ArtFormsVC
        self.navigationController?.pushViewController(artFormVC, animated: true)
    }
    
    func goToVenues() {
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let venueVC = storyboard.instantiateViewController(withIdentifier: "venueVC") as! VenueVC
        self.navigationController?.pushViewController(venueVC, animated: true)
    }
    

}

extension CreateUserVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedProfileImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension CreateUserVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return personas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return personas[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPersona = personas[row]
        personaLabel.text = selectedPersona
        textFieldDidChange()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        personaLabel.text = personas[0]
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Next", size: 17)
        
        label.text = personas[row]
        
        return label
    }
    
    
    
}

extension CreateUserVC:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
