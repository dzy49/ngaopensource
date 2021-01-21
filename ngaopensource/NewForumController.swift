//
//  newForumController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 2/16/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import Foundation
import UIKit
protocol newFourmDelegate: class {
    func addNewForum(fid:Int, title:String)
}

class NewForumController: UIViewController, UITextFieldDelegate{
    weak var delegate:newFourmDelegate?
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var fidField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBAction func doneAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addNewForumAction(_ sender: UIButton) {
        addNewForum()
    }
    func addNewForum(){
        if let fid = fidField.text{
            if let fidInt = Int(fid){
                let title = nameField.text
                delegate?.addNewForum(fid: fidInt, title: title ?? " ")
                dismiss(animated: true, completion: nil)
            }else{
                showAlertAction(title: "错误", message: "板面ID格式错误")
            }
        }else{
            showAlertAction(title: "错误", message: "板面ID不能为空")
        }
    }
    override func viewDidLoad() {
        fidField.becomeFirstResponder()
        fidField.delegate = self
        nameField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fidField {
            fidField.resignFirstResponder()
            nameField.becomeFirstResponder()
        }else{
            nameField.resignFirstResponder()
            addNewForum()
        }
        return true
    }
    
    func showAlertAction(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
