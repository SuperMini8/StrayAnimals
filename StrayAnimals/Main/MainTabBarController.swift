//
//  MainTabBarController.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/10/7.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let list = makeTab(
            rootVC: ListViewController(),
            title: "浪浪們",
            image: nil,
            selectedImage: nil
        )
        viewControllers = [
            list
        ]
    }
    
    private func makeTab(
        rootVC: UIViewController,
        title: String,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UIViewController {
        let nav = UINavigationController(rootViewController: rootVC)
        
        navigationController?.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
        return nav
    }
    
}
