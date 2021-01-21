//
//  HomeViewController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 1/26/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
protocol DoneButtonDelegate: class {
    func toggleDoneButtonOn()
    func doneButtonStatus() -> Bool
}

protocol EditFourmDelegate:class {
    func doneEditing()
}

class HomeViewController : ButtonBarPagerTabStripViewController, DoneButtonDelegate, UIAdaptivePresentationControllerDelegate{
    func doneEditing() {
        loadFromPlist()
        reloadPagerTabStripView()
    }
    
    public func presentationControllerDidDismiss(
       _ presentationController: UIPresentationController)
     {
       doneEditing()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func doneButtonStatus() -> Bool {
        return doneButton
    }
    var vcArr:[UIViewController]=[]
    var doneButton = false
    func toggleDoneButtonOn() {
        if self.navigationItem.rightBarButtonItem == nil {
            createDoneButton()
            createEditButton()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        doneButton = true
    }
    
    func toggleDoneButtonOff() {
        self.navigationItem.rightBarButtonItem = nil
        doneButton = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    var subForums:[SubForumModel] = []
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        vcArr = []
        for forums in subForums{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menu") as! SubForumMenuController
            vc.subForums = forums
            vc.delegate = self
            vcArr.append(vc)
        }
        return vcArr
    }
    
    func loadFromPlist(){
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("subForumsSaved.plist")
        let data = try? Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        if let plistData = data{
            subForums = try! decoder.decode([SubForumModel].self, from: plistData)
        }else{
            let burl = Bundle.main.url(forResource: "subForums", withExtension: "plist")!
            let bdata = try! Data(contentsOf: burl)
            subForums = try! decoder.decode([SubForumModel].self, from: bdata)
        }
        
    }
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor(named: "brown")
        settings.style.buttonBarItemBackgroundColor = UIColor(named: "brown")
        //settings.style.buttonBarMinimumLineSpacing = 20
        settings.style.buttonBarItemsShouldFillAvailableWidth=true
        settings.style.selectedBarBackgroundColor = UIColor(named: "brownBar")!
        settings.style.selectedBarHeight = 3.0
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        //let url = Bundle.main.url(forResource: "subForums", withExtension: "plist")!
        loadFromPlist()
        UINavigationBar.appearance().tintColor = UIColor.white
        //createDoneButton()
        if UserDefaults.standard.object(forKey: "savedTopics") == nil{
            let temp:[SavedTopic] = []
            UserDefaults.standard.set(try? PropertyListEncoder().encode(temp), forKey: "savedTopics")
        }
        //[Int : [Int : __R]]
        if UserDefaults.standard.object(forKey: "savedTopicReplies") == nil{
            let temp:[Int : [Int : __R]] = [:]
            UserDefaults.standard.set(try? PropertyListEncoder().encode(temp), forKey: "savedTopicReplies")
        }else{
            if let data = UserDefaults.standard.object(forKey: "savedTopicReplies") as? Data{
                let saved = try? PropertyListDecoder().decode([Int : [Int : __R]].self, from: data)
                for i in saved!{
                    for j in i.value{
                        j.value.converted = true
                    }
                }
                
                Model.topics = saved!
            }
        }
        if UserDefaults.standard.bool(forKey: "userAgreementState") == false {
            performSegue(withIdentifier: "userAgreement", sender: nil)
        }
        
        
        super.viewDidLoad()
        //Model.getLogin()
        
        
    }
    
    func createDoneButton(){
        let button = UIButton.init(type: .custom)
        button.setTitle("  完成  ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(self.doneButtonAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func createEditButton(){
        let button = UIButton.init(type: .custom)
        //button.setTitle("  完成  ", for: .normal)
        button.setImage(UIImage(systemName: "pencil.and.ellipsis.rectangle"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        //button.layer.borderWidth = 2
        //button.layer.cornerRadius = 10
        //button.layer.borderColor = UIColor.white.cgColor
        
        button.addTarget(self, action: #selector(self.editButtonAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func doneButtonAction(){
        var vc = vcArr[currentIndex] as! SubForumMenuController
        vc.longPressedEnabled = false
        vc.subForumCollectionView.reloadData()
        toggleDoneButtonOff()
    }
    
    @objc func editButtonAction(){
        performSegue(withIdentifier: "editMenu", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editMenu"){
            segue.destination.presentationController?.delegate = self
        }
    }
    
}

