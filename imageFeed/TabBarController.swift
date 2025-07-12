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

        // ImagesListViewController
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)

        // ProfileViewController
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)

        profileViewController.view.backgroundColor = UIColor.ypBlack
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
