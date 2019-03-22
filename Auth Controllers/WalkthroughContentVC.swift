//
//  WalkthroughContentVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// This file allows the User to navigate through a UIPageViewController to learn a little about what StudioSesh can do for them before they sign up.

class WalkthroughContentVC: UIViewController {
    
    @IBOutlet weak var backgroundImg: UIImageView! // background images
    
    @IBOutlet weak var contentLabel: UILabel! // intro text
    
    @IBOutlet weak var pageControl: UIPageControl! // dot indicators
    
    @IBOutlet weak var nextBtn: UIButton! // button to next page
    
    var index = 0 // pageIndex
    var imageFileName = ""
    var content = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        contentLabel.text = content
        backgroundImg.image = UIImage(named: imageFileName)
        
        pageControl.currentPage = index
        // switch below checks if button should be "next" or "done" based on page index. If last page, done button appears, otherwise arrow appears
        switch index {
        case 0...1:
            nextBtn.setImage(UIImage(named: "white-arrow.png"), for: .normal)
        case 2:
            nextBtn.setImage(UIImage(named: "check-mark.png"), for: .normal)
        default:
            break
        }
    }
    
    
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        // checks if User has navigated walkthrough before
        switch index {
        case 0...1:
            let pageVC = parent as! WalkthroughVC
            pageVC.forward(index: index)
        case 2:
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
        default:
            print("")
        }
    }
    

}
