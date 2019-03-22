//
//  VenueVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/3/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
@IBDesignable

class VenueVC: UIViewController {

    @IBOutlet weak var venueNameLabel: UITextField!
    
    @IBOutlet weak var venuePositionLabel: UITextField!
    
    @IBOutlet weak var venuePointOfContactLabel: UITextField!
    
    @IBOutlet weak var telephoneNumberLabel: UITextField!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    let positions = ["Owner", "Manager/Director", "Other Employee"]
    
    var selectedPosition: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(VenueVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)

        createPicker()
        createToolbar()
    }
    
    func createPicker() {
        
        let picker = UIPickerView()
        picker.delegate = self
        
        venuePositionLabel.inputView = picker
        
        picker.backgroundColor = .white
    }
    
    func createToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        toolbar.barTintColor = #colorLiteral(red: 0.1059608385, green: 0.7958640456, blue: 0.07565600425, alpha: 1)
        toolbar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(VenueVC.keyboardDismiss))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        venuePositionLabel.inputAccessoryView = toolbar
    }
    
    
    func handleTextField() {
        venueNameLabel.addTarget(self, action: #selector(VenueVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        venuePositionLabel.addTarget(self, action: #selector(VenueVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        venuePointOfContactLabel.addTarget(self, action: #selector(VenueVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        telephoneNumberLabel.addTarget(self, action: #selector(VenueVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let name = venueNameLabel.text, !name.isEmpty, let position = venuePositionLabel.text, !position.isEmpty, let pointOfContact = venuePointOfContactLabel.text, !pointOfContact.isEmpty, let telephone = telephoneNumberLabel.text, !telephone.isEmpty else {
            doneBtn.setTitleColor(UIColor.lightGray, for: .normal)
            doneBtn.isEnabled = false
            return
        }
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.isEnabled = true
    }
    
    @objc func keyboardDismiss() {
        textFieldDidChange()
        view.endEditing(true)
    }

    @IBAction func doneBtnWasPressed(_ sender: Any) {
        let venueName = venueNameLabel.text
        let venuePosition = venuePositionLabel.text
        let venuePointOfContact = venuePointOfContactLabel.text
        let telephoneNumber = telephoneNumberLabel.text
        
        sendDataToDatabase(venueName: venueName!, venuePointOfContact: venuePointOfContact!, telephoneNumber: telephoneNumber!, venuePosition: venuePosition!)
        goToMain()
    }
    
    func sendDataToDatabase(venueName: String, venuePointOfContact: String, telephoneNumber: String, venuePosition: String) {
        let ref = Database.database().reference()
        let venueReference = ref.child("venues")
        let newVenueId = venueReference.childByAutoId().key
        let newVenueReference = venueReference.child(newVenueId)
        newVenueReference.setValue((["venueName" : venueName, "venuePointOfContact" : venuePointOfContact, "telephone" : telephoneNumber, "venuePosition" : venuePosition])) { (error, ref) in
            if error != nil {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                return
            }
            ProgressHUD.showSuccess("You're all set!")
        }
    }
    
    func goToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        // let searchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! Search_HistoryVC
        self.navigationController?.pushViewController(initial!, animated: true)
    }
}

extension VenueVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return positions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return positions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPosition = positions[row]
        venuePositionLabel.text = selectedPosition
        textFieldDidChange()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        venuePositionLabel.text = positions[0]
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Next", size: 17)
        
        label.text = positions[row]
        
        return label
    }
    
    
    
}
