//
//  ConfirmDoneVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/12/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import BEMCheckBox

class ConfirmDoneVC: UIViewController {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var ximage: UIImageView!
    
    @IBOutlet weak var displayMessage: UILabel!
    
    @IBOutlet weak var returnToHomeBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ximage.isHidden = true
        self.displayMessage.text = ""
        self.checkBox.boxType = .circle
    }
    
    @IBAction func returnToHomeBtnWasPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    


}
