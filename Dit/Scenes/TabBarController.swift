//
//  TabBarController.swift
//  Dit
//
//  Created by 강태준 on 2022/09/05.
//

import UIKit
import SnapKit

import FirebaseAuth


final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .systemBackground
        setupTabBar()
    }
}


private extension TabBarController {
    func setupTabBar() {        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        viewControllers = [homeVC, profileVC]
    }
}
