//
//  WalkthroughVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// This file is the control behind StudioSesh's introductory pages.

class WalkthroughVC: UIPageViewController, UIPageViewControllerDataSource {

    var pageContent = ["Share your portfolio of art with others, find like-minded individuals and establishments that share your passions, and grow your network.", "Connect with, collaborate with, and review other artists and venues you've worked with before.", "Book creative space at venues in record time with a simple, streamlined booking platform."] // labels for each page
    
    var pageImage = ["painter.png", "actor.png", "musician.png"] // background images for each page
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let startingVC = viewControllerAtIndex(index: 0) {
            setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        } // set scroll starting point
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkthroughContentVC).index
        index += 1
        return viewControllerAtIndex(index: index)
    } // go to next page
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkthroughContentVC).index
        index -= 1
        return viewControllerAtIndex(index: index)
    } // go to previous page
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentVC? {
        if index < 0 || index >= pageContent.count {
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentVC") as? WalkthroughContentVC {
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageFileName = pageImage[index]
            
            return pageContentVC
        } // return pages
        return nil
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    } // function that scrolls to next page
    
    
    

}
