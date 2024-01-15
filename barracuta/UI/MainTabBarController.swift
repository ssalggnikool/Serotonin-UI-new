//
//  ViewController.swift
//  pockiiau
//
//  Created by samiiau on 2/27/23.
//  Copyright © 2023 samiiau. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstVC = JailbreakViewController()
        let secondVC = OptionsViewController()

        firstVC.tabBarItem = UITabBarItem(title: "Jailbreak", image: UIImage(systemName: "sparkles"), tag: 0)
        secondVC.tabBarItem = UITabBarItem(title: "Options", image: UIImage(systemName: "gear"), tag: 1)

        setViewControllers([firstVC, secondVC], animated: false)

        selectedIndex = 0
        
        
    }
    
}
