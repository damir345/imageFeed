//
//  TabBarController.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 14/06/25.
//

import UIKit
 
final class TabBarController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
//        let profileViewController = storyboard.instantiateViewController(
//            withIdentifier: "ProfileViewController"
//        )
        
        let profileViewController = ProfileViewController()
        
        profileViewController.view.backgroundColor = UIColor.ypBlack
        
        profileViewController.tabBarItem = UITabBarItem(
                       title: "",
                       image: UIImage(named: "tab_profile_active"),
                       selectedImage: nil
                   )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
}
