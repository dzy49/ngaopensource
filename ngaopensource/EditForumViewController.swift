//
//  EditForumViewController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 6/4/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import UIKit
class SubFourmTableViewCell: UITableViewCell{
    @IBOutlet weak var subFourmTitle: UILabel!
}

class EditForumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var subForums:[SubForumModel]?
    var delegate:EditFourmDelegate?
    
    @IBOutlet weak var finishBtn: UIButton!
    @IBAction func finishEditing(_ sender: UIButton) {
        saveToPlist(subForums: subForums)
        print("?")
    }
    
    @IBAction func addSubFourm(_ sender: UIButton) {
        let alert  = UIAlertController(title: "输入新分类名", message: "" ,preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let newSubFourm = SubForumModel(dictionary: [:])
            newSubFourm.title = textField?.text
           // self.subForums?[indexPath.row].title = textField?.text
            self.subForums?.append(newSubFourm)
            self.subFourmTableView.reloadData()
        }))
        let okAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(okAction)
        
        alert.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subForums?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subFourmTableView.dequeueReusableCell(withIdentifier: "subFourmTableViewCell", for: indexPath)
        if let myCell =  cell as? SubFourmTableViewCell {
            myCell.subFourmTitle.text = subForums?[indexPath.row].title
        }
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subFourmTableView.delegate = self
        subFourmTableView.dataSource = self
        // Do any additional setup after loading the view.
        //let url = Bundle.main.url(forResource: "subForums", withExtension: "plist")!
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("subForumsSaved.plist")
        
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        subForums = try! decoder.decode([SubForumModel].self, from: data)
        subFourmTableView.reloadData()
        subFourmTableView.isEditing = true
        //subFourmTableView.reorder
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item : SubForumModel = (subForums?[sourceIndexPath.row])!;
        subForums?.remove(at: sourceIndexPath.row)
        subForums?.insert(item, at: destinationIndexPath.row)
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "删除") {  (contextualAction, view, boolValue) in
            self.subForums?.remove(at: indexPath.row)
            self.subFourmTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let contextItemSave = UIContextualAction(style: .normal, title: "编辑") {  (contextualAction, view, boolValue) in
            let alert  = UIAlertController(title: "输入新分类名", message: "" ,preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                self.subForums?[indexPath.row].title = textField?.text
                self.subFourmTableView.reloadRows(at: [indexPath], with: .automatic)
            }))
            let okAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            alert.addAction(okAction)
            
            alert.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem,contextItemSave])
        
        return swipeActions
    }
    @IBOutlet weak var subFourmTableView: UITableView!
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func saveToPlist(subForums:[SubForumModel]?){
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("subForumsSaved.plist")
        
        do {
            let data = try encoder.encode(subForums)
            try data.write(to: path)
        } catch {
            print(error)
        }
    }
    
    
    
}
