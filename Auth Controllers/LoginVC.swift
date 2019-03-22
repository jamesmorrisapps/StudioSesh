//
//  LoginVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/25/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics

@IBDesignable

// This file acts as a storage file for all functions with backend functionality relative to User Authentication, specifically Sign In.

class LoginVC: UIViewController {
    @IBOutlet weak var loginStackView: UIStackView!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var toCreateUserBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInBtn.layer.cornerRadius = 5
        signInBtn.isEnabled = false
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(LoginVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
    }

    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let hasViewedWalkthrough = defaults.bool(forKey: "hasViewedWalkthrough")
        if !hasViewedWalkthrough {
            if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughVC") as? WalkthroughVC {
                present(pageVC, animated: true, completion: nil)
            }
        }
        // IGNORE FOR NOW (Auto Sign In):
//        if API.User.CURRENT_USER != nil {
//            self.goToMain()
//        }
    }
    
    func handleTextField() {
        emailLabel.addTarget(self, action: #selector(LoginVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordLabel.addTarget(self, action: #selector(LoginVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailLabel.text, !email.isEmpty, let password = passwordLabel.text, !password.isEmpty else {
            signInBtn.setTitleColor(UIColor.lightGray, for: .normal)
            signInBtn.isEnabled = false
            return
        }
        signInBtn.setTitleColor(UIColor.white, for: .normal)
        signInBtn.isEnabled = true
    }
        
    @IBAction func signInBtnWasPressed(_ sender: Any) {
        let email = emailLabel.text
        let password = passwordLabel.text

        ProgressHUD.show("Logging you in...", interaction: false)

        if (emailLabel.text?.isEmpty)! && (passwordLabel.text?.isEmpty)! {
            // Display error message and shake login button
            signInBtn.wiggle()
        } else {
            AuthService.signIn(email: email!, password: password!, onSuccess: {
                ProgressHUD.showSuccess("Bingo! You're in. Welcome to StudioSesh!")
                self.goToMain()
            }) {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                self.signInBtn.wiggle()
            }
        }
    }
    
    @IBAction func toCreateUserBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let createUserVC = storyboard.instantiateViewController(withIdentifier: "createUserVC") as! CreateUserVC
        self.navigationController?.pushViewController(createUserVC, animated: true)
    }
    
    func goToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        //let searchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! Search_HistoryVC
        self.navigationController?.pushViewController(initial!, animated: true)
    }
    
    

    
    


}
