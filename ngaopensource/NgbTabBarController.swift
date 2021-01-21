//
//  NgbTabBarController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 2/22/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import Foundation
import UIKit
class NgbTabBarController: UITabBarController{
    override func viewDidLoad() {
      //  tabBar.barTintColor = UIColor(named: "Brown")
        tabBar.isTranslucent = false
        tabBar.layer.borderWidth = 0.50
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
    }
}
