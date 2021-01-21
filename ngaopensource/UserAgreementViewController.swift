//
//  UserAgreementViewController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 6/13/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import UIKit

class UserAgreementViewController: UIViewController {
    @IBAction func agreeAction(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "userAgreementState")
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
