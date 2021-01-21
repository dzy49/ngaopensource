//
//  TopicController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/29/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import XLActionController

class TopicController:ButtonBarPagerTabStripViewController{
    var tid:Int?
    var replyNum:Int?
    //var topicModel:__R?
    var topicModelList:[Int:__R]=[:]
    var pageNum:Int = 1
    var saved:Bool?
    //public var buttonBarHeight: CGFloat?
    @IBOutlet weak var lastPageButton: UIButton!
    @IBAction func moveToLastPage(_ sender: UIButton) {
        moveToViewController(at: pageNum - 1, animated: true)
    }
    @IBAction func dismissTopic(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        /*
         settings.style.buttonBarBackgroundColor = util().darkeryellow
         settings.style.buttonBarItemBackgroundColor = .black
         settings.style.selectedBarBackgroundColor = .white
         //settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
         settings.style.selectedBarHeight = 2.0
         settings.style.buttonBarMinimumLineSpacing = 0
         settings.style.buttonBarItemLeftRightMargin = 0
         
         //self.settings.style.selectedBarHeight = 2
         //self.settings.style.buttonBarHeight=10
         super.viewDidLoad()
         view.setNeedsLayout()
         view.layoutIfNeeded()
         */
        settings.style.buttonBarBackgroundColor = UIColor(named: "brown")
        settings.style.buttonBarItemBackgroundColor = UIColor(named: "brown")
        //settings.style.buttonBarMinimumLineSpacing = 20
        settings.style.buttonBarItemsShouldFillAvailableWidth=true
        settings.style.selectedBarBackgroundColor = UIColor(named: "brownBar")!
        
        super.viewDidLoad()
        
    }
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        //print("??")
        if progressPercentage >= 1.0 && !indexWasChanged {
            let leftIndex = self.currentIndex - 1
            let rightIndex = self.currentIndex + 1
            if leftIndex >= 0 {
                let c = viewControllers[leftIndex]
                if !c.isViewLoaded {
                    c.loadViewIfNeeded()
                    
                }
            }
            if rightIndex < self.viewControllers.count {
                let c = viewControllers[rightIndex] as! ReplyController
                if !c.isViewLoaded {
                    //c.loadViewIfNeeded()
                    //c.prepareData()
                    let _ = c.view
                    let _ = c.replyTableView
                }
            }
        }
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var pages:[UIViewController] = []
        
        if let rNum = replyNum{
            pageNum = Int(ceil((Double(rNum+1)/20.0)))
        }
        /*
         
         
         if let replys = topicModel?.replys{
         for reply in replys{
         let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "child1") as! ReplyController
         child_1.info=reply.content ?? ""
         pages.append(child_1)
         }
         }
         */
        for i in 1 ... pageNum{
            let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "child1") as! ReplyController
            child_1.info = String(i)
            //child_1.topicModel=topicModelList[i]
            child_1.tid = tid
            pages.append(child_1)
        }
        return pages
    }
    
}
class ReplyController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ReplyOptionDelegate{
    
    
    var topicModel:__R?
    var tid:Int?
    var flag = true
    var saved:Bool?
    //var topicModelList:[__R]?
    @IBOutlet weak var replyTableView: ReplyTableView!
    
    func showMoreOption(cell: ReplyTableViewCell) {
        let actionSheet = SortActionController()
        // set up a header title
        
        actionSheet.headerData = nil
        guard let indexPath = self.replyTableView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        // Add some actions, note that the first parameter of `Action` initializer is `ActionData`.
        
        actionSheet.addAction(Action(ActionData(title: "隐藏帖子", subtitle: "", image: UIImage(named: "hide")!), style: .default, handler: { action in
            
            //print(indexPath.row)
            self.topicModel?.replys.remove(at: indexPath.row)
            self.replyTableView.reloadData()
        }))
        actionSheet.addAction(Action(ActionData(title: "屏蔽用户", subtitle: "", image: UIImage(named: "block")!), style: .default, handler: { action in
            var blockList = UserDefaults.standard.array(forKey: "blockedUsers")
            blockList?.append(self.topicModel?.replys[indexPath.row].authorid)
            UserDefaults.standard.set(blockList, forKey: "blockedUsers")
            print(blockList)
            //self.filterBlockedUsers()
            self.replyTableView.reloadData()
        }))
        actionSheet.addAction(Action(ActionData(title: "举报", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
            //self.reportOptions(cell: cell)
            
        }))
        // present actionSheet like any other view controller
        present(actionSheet, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        print("?")
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicModel?.replys.count ?? 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           if replyTableView.contentOffset.y >= (replyTableView.contentSize.height - replyTableView.frame.size.height) {
            print("trigger")
            let spinner = UIActivityIndicatorView(style: .large
            
            
            
            
            )
            spinner.color = UIColor.darkGray
            spinner.hidesWhenStopped = true
            replyTableView.tableFooterView = spinner
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if info == "1" && indexPath.row == 0{
            cell = replyTableView.dequeueReusableCell(withIdentifier: "ReplyTableViewMainCell", for: indexPath)
            //cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ReplyTableViewMainCell") as! ReplyTableViewMainCell
            
            if let myCell =  cell as? ReplyTableViewMainCell {
                //myCell.delegate = self
                myCell.replyPos.text="#"+String(topicModel?.replys[indexPath.row].lou ?? 0)
                myCell.content.delegate = self
                if(flag){
                    myCell.title.text = topicModel?.replys[indexPath.row].subject
                    myCell.content.attributedText=topicModel?.replys[indexPath.row].attrContent?.attributedString
                    myCell.upVoteNum.text=String(topicModel?.replys[indexPath.row].score ?? 0)
                    myCell.authorTime.setTitle(String(topicModel?.replys[indexPath.row].authorid ?? 0), for: .normal)
                }
                if indexPath.row % 2 == 1{
                    myCell.background.backgroundColor = UIColor(named: "lightYellow")
                    myCell.content.backgroundColor = UIColor(named: "lightYellow")
                    myCell.title.backgroundColor = UIColor(named: "lightYellow")
                }else{
                    myCell.background.backgroundColor = UIColor(named: "darkYellow")
                    myCell.content.backgroundColor = UIColor(named: "darkYellow")
                    myCell.title.backgroundColor = UIColor(named: "darkYellow")
                }
            }
        }else{
            cell = replyTableView.dequeueReusableCell(withIdentifier: "ReplyTableViewCell", for: indexPath)
            if let myCell =  cell as? ReplyTableViewCell {
                myCell.delegate = self
                myCell.replyPos.text="#"+String(topicModel?.replys[indexPath.row].lou ?? 0)
                myCell.content.delegate = self
                if(flag){
                    myCell.content.attributedText=topicModel?.replys[indexPath.row].attrContent?.attributedString
                    myCell.upVoteNum.text=String(topicModel?.replys[indexPath.row].score ?? 0)
                    myCell.authorTime.setTitle(String(topicModel?.replys[indexPath.row].authorid ?? 0), for: .normal)
                }
                if indexPath.row % 2 == 1{
                    myCell.background.backgroundColor = UIColor(named: "lightYellow")
                    myCell.content.backgroundColor = UIColor(named: "lightYellow")
                }else{
                    myCell.background.backgroundColor = UIColor(named: "darkYellow")
                    myCell.content.backgroundColor = UIColor(named: "darkYellow")
                }
            }
        }
        return cell!
    }
    
    var info=""
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if(info=="1"){
            return IndicatorInfo(title: " 1")
        }
        return IndicatorInfo(title: info)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return topicModel?.replys[indexPath.row].height ?? 250.0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return topicModel?.replys[indexPath.row].height ?? 250.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        flag = false
    }
    
    override func viewDidLoad() {
        //  label.text=info
        //print(info)
        replyTableView.dataSource=self
        replyTableView.delegate=self
        //replyTableView.rowHeight = UITableView.automaticDimension
        //replyTableView.estimatedRowHeight = UITableView.automaticDimension
        //prepareData()
        //viewWillAppear(true)
        topicModel = Model.topics[self.tid!]?[Int(self.info)!]
        if Model.topics[self.tid!]?[Int(self.info)!] == nil{
            //TODO change error handling
            // DispatchQueue.global(qos: .userInitiated).async {
            // [weak self] in
            Model.loadTopic(tid: self.tid!, page: Int(self.info)!){
                response in
                //let page=Int(self.info)!
                self.topicModel = Model.topics[self.tid!]?[Int(self.info)!]
                //TODO NIL cause: empty page?
                if let tm = self.topicModel{
                    if(!tm.converted){
                        DispatchQueue.global(qos: .userInitiated).async {
                            Model.loadAttrString(tid: self.tid!, pageNum:Int(self.info)!){
                                response in
                                DispatchQueue.main.async{
                                    //  self.flag=true
                                    self.replyTableView.reloadData()
                                }
                                for (index,reply) in tm.replys.enumerated(){
                                    Model.loadImg(str: reply.attrContent?.attributedString as! NSMutableAttributedString){
                                        completion in
                                        //reply.attrContent?.attributedString = completion
                                        let screenWidth: CGFloat = UIScreen.main.bounds.width
                                        let rect = reply.attrContent?.attributedString.boundingRect(with: CGSize(width: screenWidth-16, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
                                        var titleHeight = CGFloat(0.0)
                                        if(index == 0 && self.info == "1"){
                                            titleHeight = util.heightForString(string: reply.subject ?? "")
                                        }
                                        reply.height = (rect?.height ?? 0) + 100 + titleHeight
                                        
                                        DispatchQueue.main.async{
                                            //  self.flag=true
                                            self.replyTableView.reloadData()
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            //}
        }else{
            DispatchQueue.global(qos: .userInitiated).async {
                if(!self.topicModel!.converted){
                    Model.loadAttrString(tid: self.tid!, pageNum:Int(self.info)!){
                        response in
                        DispatchQueue.main.async{
                            self.replyTableView.reloadData()
                        }
                        for (index, reply) in (Model.topics[self.tid!]?[Int(self.info)!]!.replys)!.enumerated(){
                            Model.loadImg(str: reply.attrContent?.attributedString as! NSMutableAttributedString){
                                completion in
                                //reply.attrContent?.attributedString = completion
                                let screenWidth: CGFloat = UIScreen.main.bounds.width
                                let rect = reply.attrContent?.attributedString.boundingRect(with: CGSize(width: screenWidth-16, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
                                var titleHeight = CGFloat(0.0)
                                if(index == 0 && self.info == "1"){
                                    titleHeight = util.heightForString(string: reply.subject ?? "")
                                }
                                reply.height = (rect?.height ?? 0) + 100 + titleHeight
                                DispatchQueue.main.async{
                                    self.replyTableView.reloadData()
                                }
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async{
                        // self.flag=true
                        self.replyTableView.reloadData()
                    }
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //flag=true
        
        /*
         DispatchQueue.global(qos: .background).async {
         if(Model.topics[self.tid!]?[Int(self.info)!+1]==nil){
         Model.loadTopic(tid: self.tid!, page: Int(self.info)!+1){
         response in
         //self.topicModel = Model.topics[self.tid!]?[Int(self.info)!+1]
         //self.replyTableView.reloadData()
         if((Model.topics[self.tid!]?[Int(self.info)!+1]!.converted ?? true) == false){
         Model.loadAttrString(tid: self.tid!, pageNum:Int(self.info)!+1){
         response in
         }
         }
         }
         }
         if(Model.topics[self.tid!]?[Int(self.info)!+2]==nil){
         Model.loadTopic(tid: self.tid!, page: Int(self.info)!+2){
         response in
         //self.topicModel = Model.topics[self.tid!]?[Int(self.info)!+1]
         //self.replyTableView.reloadData()
         if((Model.topics[self.tid!]?[Int(self.info)!+2]!.converted ?? true) == false){
         Model.loadAttrString(tid: self.tid!, pageNum:Int(self.info)!+2){
         response in
         }
         }
         }
         }
         }
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        flag=true
        replyTableView.reloadData()
    }
    
    override func loadViewIfNeeded() {
        
    }
    
    /* func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
     return false
     }
     */
    
}

class ReplyTableView:UITableView{
    
}

protocol ReplyOptionDelegate:class {
    func showMoreOption(cell:ReplyTableViewCell)
}

protocol MainOptionDelegate:class {
    func showMoreOption(cell:ReplyTableViewMainCell)
}

class ReplyTableViewCell:UITableViewCell{
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var device: UIButton!
    @IBOutlet weak var authorTime: UIButton!
    @IBOutlet weak var upVoteNum: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var replyPos: PaddedLabel!
    weak var delegate:ReplyOptionDelegate?
    @IBAction func moreOptionsAction(_ sender: UIButton) {
        delegate?.showMoreOption(cell: self)
    }
    
}

class ReplyTableViewMainCell:UITableViewCell{
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var device: UIButton!
    @IBOutlet weak var authorTime: UIButton!
    @IBOutlet weak var upVoteNum: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var replyPos: PaddedLabel!
    weak var delegate:MainOptionDelegate?
    @IBAction func moreOptionsAction(_ sender: UIButton) {
        delegate?.showMoreOption(cell: self)
    }
    
}
