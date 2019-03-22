//
//  SessionVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/24/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class SessionVC: UIViewController {

    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var sessionTitleTextfield: UITextField!
    
    @IBOutlet weak var sessionDescriptionTextfield: UITextField!
    
    @IBOutlet weak var sessionMemberTextfield: UITextField!
    
    @IBOutlet weak var sessionMemberLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var usernameArray = [String]()
    var chosenUsernameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        sessionMemberTextfield.delegate = self
        sessionMemberTextfield.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textfieldDidChange() {
        if sessionMemberTextfield.text == "" {
            usernameArray = []
            tableView.reloadData()
        } else {
            API.Sessions.getUsername(forSearchQuery: sessionMemberTextfield.text!.lowercased()) { (returnedUsernameArray) in
                self.usernameArray = returnedUsernameArray
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doneBtn.isHidden = true
    }
    
    
    @IBAction func doneBtnWasPressed(_ sender: Any) {
        if sessionTitleTextfield.text != "" && sessionDescriptionTextfield.text != "" {
            API.Sessions.getIds(forUsernames: chosenUsernameArray) { (idsArray) in
                var userIds = idsArray
                userIds.append((Auth.auth().currentUser?.uid)!)
                
                API.Sessions.createGroup(withTitle: self.sessionTitleTextfield.text!, andDescription: self.sessionDescriptionTextfield.text!, forUserIds: userIds, handler: { (groupCreated) in
                    if groupCreated {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("Group could not be created.")
                    }
                })
                
            }
        }
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    


}

extension SessionVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionMemberCell") as! SessionMemberCell
        let profileImage = UIImage(named: "defaultProfileImage-1")
        
        if chosenUsernameArray.contains(usernameArray[indexPath.row]) {
           cell.configureCell(profileImage: profileImage!, username: usernameArray[indexPath.row], isSelected: true)
        } else {
            cell.configureCell(profileImage: profileImage!, username: usernameArray[indexPath.row], isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SessionMemberCell
        if !chosenUsernameArray.contains(cell.usernameLabel.text!) {
            chosenUsernameArray.append(cell.usernameLabel.text!)
            sessionMemberLabel.text = chosenUsernameArray.joined(separator: ", ")
            doneBtn.isHidden = false
        } else {
            chosenUsernameArray = chosenUsernameArray.filter({ $0 != cell.usernameLabel.text!})
            if chosenUsernameArray.count >= 1 {
                sessionMemberLabel.text = chosenUsernameArray.joined(separator: ", ")
            } else {
                sessionMemberLabel.text = "Add Users to Your Session"
                doneBtn.isHidden = true
            }
        }
    }
}

extension SessionVC: UITextFieldDelegate {
    
}
