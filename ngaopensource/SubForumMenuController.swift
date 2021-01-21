//
//  SubForumMenuController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 1/27/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Alamofire
import AlamofireImage

class Forum:Decodable, Encodable{
    var title:String?
    var fid:String?
    init(dictionary: [String:Any]) {
        // set the Optional ones
        self.fid = dictionary["fid"] as? String
        self.title = dictionary["title"] as? String
    }
    init(fid: String,title:String) {
        // set the Optional ones
        self.fid = fid
        self.title = title
    }
}
class SubForumModel:Decodable, Encodable{
    var title:String?
    var items:[Forum]?
    init(dictionary: [String:Any]) {
        // set the Optional ones
        self.title = dictionary["title"] as? String
        self.items = dictionary["items"] as? [Forum]
    }
}

class SubForumMenuController : UIViewController, IndicatorInfoProvider, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SubForumIconCellProtocol, newFourmDelegate{
    func addNewForum(fid: Int, title: String) {
        if subForums?.items != nil {
            subForums?.items!.append(Forum(fid:String(fid),title: title))
        }else{
            subForums?.items = []
            subForums?.items?.append(Forum(fid:String(fid),title: title))
        }
        subForumCollectionView.reloadData()
    }
    
    func deleteForum(cell: SubForumIconCell) {
        guard let indexPath = self.subForumCollectionView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        //print(indexPath.row)
        subForums?.items?.remove(at: indexPath.row)
        subForumCollectionView.reloadData()
    }
    
    func ToggledoneButtonOn() {
        delegate?.toggleDoneButtonOn()
    }
    weak var delegate: DoneButtonDelegate?
    var doneButton: UIBarButtonItem?
    var subForums: SubForumModel?
    var longPressedEnabled = false
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        var screenWidth:CGFloat = 0
        if(screenSize.width < screenSize.height){
            screenWidth = screenSize.width
        }else{
            screenWidth = screenSize.height
        }
        return CGSize(width: (screenWidth-45)/3, height: (screenWidth-45)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if let items = subForums!.items{
            count  = items.count
        }
        
        if(longPressedEnabled){
            return count + 1
        }
        else{
            return count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(!longPressedEnabled){
            performSegue(withIdentifier: "showSubForum", sender: indexPath)
        }else{
            if indexPath.row == subForums!.items?.count ?? 0{
                performSegue(withIdentifier: "newForum", sender: indexPath)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubForum" {
            if let viewController = segue.destination as? TopicListController {
                if let indexPath = sender as? IndexPath {
                    let model=subForums!.items![indexPath.row]
                    let key=model.title
                    viewController.fid = Int(model.fid!)
                    viewController.navigationItem.title = key
                }
            }
        }
        if segue.identifier == "newForum"{
            if let viewController = segue.destination as? NewForumController{
                viewController.delegate = self
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if( (subForums!.items == nil || indexPath.row == subForums!.items?.count) && longPressedEnabled){
            let cell = subForumCollectionView.dequeueReusableCell(withReuseIdentifier: "SubForumIconCell", for: indexPath)
            if let myCell =  cell as? SubForumIconCell {
                myCell.delegate = self
                myCell.name.text = "新增"
                myCell.icon.image = UIImage(named:"add")
                myCell.name.textColor = .systemBlue
                myCell.deleteButton.isHidden = true
            }
            return cell
        }
        let cell = subForumCollectionView.dequeueReusableCell(withReuseIdentifier: "SubForumIconCell", for: indexPath)
        if let item = subForums!.items{
       
        if let myCell =  cell as? SubForumIconCell {
            let model = item[indexPath.row]
            let key = model.title
            myCell.delegate = self
            myCell.name.text = key
            myCell.name.textColor = .label
            if let icon = util.loadImageFromDiskWith(fileName: String(model.fid!)){
                myCell.icon.image = icon
            }else{
                let imageUrl = "https://img4.nga.178.com/proxy/cache_attach/ficon/" + String(model.fid!) + "u.png"
                Alamofire.request(imageUrl, method: .get).responseImage { response in
                    guard let image = response.result.value else {
                        print(imageUrl)
                        print("??")
                        return
                    }
                    util.saveImage(imageName: String(model.fid!), image: image)
                    myCell.icon.image = image
                }
            }
            if longPressedEnabled {
                myCell.startAnimate()
                myCell.deleteButton.isHidden = false
            }else{
                myCell.stopAnimate()
                myCell.deleteButton.isHidden = true
            }
            
        }
        }
        return cell
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: subForums?.title)
    }
    override func viewDidLoad() {
        UINavigationBar.appearance().tintColor = UIColor.white
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        subForumCollectionView.addGestureRecognizer(longPressGesture)
    }
    override func viewDidAppear(_ animated: Bool) {
        if (delegate?.doneButtonStatus())! {
            longPressedEnabled = true
        }else{
            longPressedEnabled = false
        }
        subForumCollectionView.reloadData()
    }
    
    @objc func longTap(_ gesture: UIGestureRecognizer){
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = subForumCollectionView.indexPathForItem(at: gesture.location(in: subForumCollectionView)) else {
                return
            }
            subForumCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            subForumCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            subForumCollectionView.endInteractiveMovement()
            //doneBtn.isHidden = false
            longPressedEnabled = true
            self.subForumCollectionView.reloadData()
        default:
            subForumCollectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if(longPressedEnabled && indexPath.row != subForums?.items?.count){
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let tmp = subForums!.items![sourceIndexPath.item]
        subForums!.items![sourceIndexPath.item] = subForums!.items![destinationIndexPath.item]
        subForums!.items![destinationIndexPath.item] = tmp
        
        subForumCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.row == (subForums?.items!.count)!{
            return IndexPath(row: (subForums?.items!.count)!-1, section: 0)
        }
        return proposedIndexPath
    }
    
    @IBOutlet weak var subForumCollectionView: UICollectionView!
}
protocol SubForumIconCellProtocol : class {
    func ToggledoneButtonOn()
    func deleteForum(cell:SubForumIconCell)
}
class SubForumIconCell : UICollectionViewCell{
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    weak var delegate : SubForumIconCellProtocol?
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deleteForum(_ sender: UIButton) {
        delegate?.deleteForum(cell: self)
    }
    var fid:Int?
    func startAnimate() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = 99999
        
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.timeOffset = 290 * drand48()
        
        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey:"animate")
        //self.navigationItem.rightBarButtonItem
        delegate?.ToggledoneButtonOn()
        //isAnimate = true
    }
    func stopAnimate() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "animate")
        //self.removeBtn.isHidden = true
        //isAnimate = false
    }
    
}
