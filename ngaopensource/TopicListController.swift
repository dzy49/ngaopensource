//
//  FirstViewController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/21/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import TagListView
import XLActionController

enum Order:String{
    case normal
    case replies
    case date
}

class TopicListController: UIViewController, UITableViewDelegate, UITableViewDataSource, TopicOptionDelegate {
    
    func reportOptions(cell: TopicListTableCell){
        let actionSheet = SortActionController()
        actionSheet.headerData = "请选择理由"
        guard let indexPath = self.topicListTableView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        actionSheet.addAction(Action(ActionData(title: "涉黄信息", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "不实信息", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "垃圾营销", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "人身攻击", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "有害信息", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "内容抄袭", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "违法信息", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        actionSheet.addAction(Action(ActionData(title: "诈骗信息", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    func showMoreOption(cell: TopicListTableCell) {
        let actionSheet = SortActionController()
        // set up a header title
        
        actionSheet.headerData = nil
        guard let indexPath = self.topicListTableView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        // Add some actions, note that the first parameter of `Action` initializer is `ActionData`.
        actionSheet.addAction(Action(ActionData(title: "保存", subtitle: "", image: UIImage(named: "save")!), style: .default, handler: { action in
            let topic = (self.topicListModel?.topics[indexPath.row])!
            if let data = UserDefaults.standard.object(forKey: "savedTopics") as? Data{
                var saved = try? PropertyListDecoder().decode([SavedTopic].self, from: data)
                let topic = SavedTopic(topic: (self.topicListModel?.topics[indexPath.row])!, savedTime:Data())
                saved?.append(topic)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(saved), forKey: "savedTopics")
            }
            let replyNum = topic.replies
            var pageNum = 1
            if let rNum = replyNum{
                pageNum = Int(ceil((Double(rNum+1)/20.0)))
            }
            self.loadAllPages(tid: topic.tid!, page: 1, lastPage: pageNum)
            
            
            
        }))
        actionSheet.addAction(Action(ActionData(title: "隐藏帖子", subtitle: "", image: UIImage(named: "hide")!), style: .default, handler: { action in
            
            //print(indexPath.row)
            self.topicListModel?.topics.remove(at: indexPath.row)
            self.topicListTableView.reloadData()
        }))
        actionSheet.addAction(Action(ActionData(title: "屏蔽用户", subtitle: "", image: UIImage(named: "block")!), style: .default, handler: { action in
            var blockList = UserDefaults.standard.array(forKey: "blockedUsers")
            blockList?.append(self.topicListModel?.topics[indexPath.row].authorid)
            UserDefaults.standard.set(blockList, forKey: "blockedUsers")
            print(blockList)
            self.filterBlockedUsers()
            self.topicListTableView.reloadData()
        }))
        actionSheet.addAction(Action(ActionData(title: "举报", subtitle: "", image: UIImage(named: "report")!), style: .default, handler: { action in
            self.reportOptions(cell: cell)
            
        }))
        // present actionSheet like any other view controller
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var topicListTableView: TopicListTableView!
    @IBOutlet weak var sortButton: UIButton!
    var topicListModel:__T?
    //var model = Model()
    var preLoadpage = 5
    var page = 1
    var loadFlag = true
    var fid:Int?
    var order:Order = .replies
    @IBOutlet weak var orderImage: UIImageView!
    var progressCount = 0
    
    func loadAllPages(tid:Int, page:Int, lastPage:Int){
        DispatchQueue.global(qos: .background).async {
            Model.loadTopic(tid: tid, page: page){
                _ in
                Model.loadAttrString(tid: tid, pageNum: page, withPHImg: false){
                    _ in
                    if let data = UserDefaults.standard.object(forKey: "savedTopicReplies") as? Data{
                        var saved = try? PropertyListDecoder().decode([Int : [Int : __R]].self, from: data)
                        saved?[tid] = Model.topics[tid]
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(saved), forKey: "savedTopicReplies")
                    }
                    if(page < lastPage){
                        self.loadAllPages(tid: tid, page: page + 1, lastPage: lastPage)
                    }else{
                        print("finish loading")
                    }
                }
            }
        }
    }
    // present actionSheet like any other view controller
    
    @IBAction func changeSort(_ sender: UIButton) {
        // Instantiate custom action sheet controller
        let actionSheet = SortActionController()
        // set up a header title
        actionSheet.settings.cancelView.hideCollectionViewBehindCancelView = false
        actionSheet.settings.statusBar.modalPresentationCapturesStatusBarAppearance = false
        actionSheet.settings.statusBar.showStatusBar = false
        
        actionSheet.headerData = "帖子排序"
        // Add some actions, note that the first parameter of `Action` initializer is `ActionData`.
        actionSheet.addAction(Action(ActionData(title: "发帖时间", subtitle: "", image: UIImage(named: "new")!), style: .default, handler: { action in
            self.order = .date
            
            self.topicListModel?.topics.sort(by: { $0.postdate ?? 0 > $1.postdate ?? 0 })
            UserDefaults.standard.set("date", forKey: "sortTopic")
            self.setOrderButtonTitle()
            
            self.topicListTableView.reloadData()
        }))
        actionSheet.addAction(Action(ActionData(title: "回复数量", subtitle: "", image: UIImage(named: "reply")!), style: .default, handler: { action in
            self.order = .replies
            self.topicListModel?.topics.sort(by: { $0.replies ?? 0 > $1.replies ?? 0 })
            UserDefaults.standard.set("replies", forKey: "sortTopic")
            self.setOrderButtonTitle()
            
            
            self.topicListTableView.reloadData()
        }))
        actionSheet.addAction(Action(ActionData(title: "默认排序", subtitle: "", image: UIImage(named: "normal")!), style: .default, handler: { action in
            self.order = .normal
            UserDefaults.standard.set("normal", forKey: "sortTopic")
            self.setOrderButtonTitle()
            
            
            self.topicListTableView.reloadData()
            
        }))
        // present actionSheet like any other view controller
        present(actionSheet, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model=topicListModel{
            return model.topics.count
        }else{
            return 0
        }
    }
    @IBAction func unwindFromTopicController(_ sender:UIStoryboardSegue){
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topicListTableView.dequeueReusableCell(withIdentifier: "TopicListTableCell", for: indexPath)
        if let myCell =  cell as? TopicListTableCell {
            myCell.delegate = self
            if let model = topicListModel{
                let t = model.topics[(indexPath.row)]
                if let subject = t.subjectNoTags{
                    // let (tags,title) = util().getTag(subject: subject)
                    myCell.subject.text = subject
                    myCell.tagList.removeAllTags()
                    if let tags=t.tags{
                        if(tags.count != 0){
                            /*for tag in tags{
                             myCell.tagList.addTag(tag, withBackgroundColor: .red)
                             }*/
                            myCell.tagList.addTags(tags)
                            
                        }
                    }
                }
                myCell.tid=t.tid
                myCell.content.text = t.content
                
                myCell.authorTime.text = t.author! + " • " + util.dateFormatted(input:Double(t.postdate!), withFormat : "MM-dd-yyyy HH:mm")
                if let replynum = t.replies{
                    myCell.commentNum.text = String(replynum)
                }
                if let upvoteNum = t.score{
                    myCell.upVote.text = String(upvoteNum)
                }
                
                if let image = t.image{
                    if let sourceImage =  UIImage(data: image){
                        let resizedImage=util.resizeImg(sourceImage: sourceImage, i_width: myCell.topicImage.frame.width)
                        myCell.topicImage.image = resizedImage
                    }
                }else{
                    myCell.topicImage.image = nil
                }
                if indexPath.row % 2 == 1{
                    myCell.background.backgroundColor = UIColor(named: "lightYellow")
                    //util().lightyellow
                }else{
                    myCell.background.backgroundColor =  UIColor(named: "darkYellow")
                }
                
            }
        }
        
        
        return cell
        //return UITableViewCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if(loadFlag){
                loadFlag=false
                loadNextPage()
            }
        }
    }
    func loadNextPage(){
        self.progressCount = 0
        self.progressBar.isHidden = false
        self.progressBar.alpha = 1
        self.progressBar.setProgress(0.2, animated: false)
        page = page + 1
        Model.getTopicList(fid: fid!,page: page){
            response in
            if(response == nil){
                self.showAlertAction(title: "错误", message: "载入板块错误")
                return
            }
            switch self.order{
            case .replies:
                response!.topics.sort(by: { $0.replies ?? 0 > $1.replies ?? 0 })
            case .date:
                response!.topics.sort(by: { $0.postdate ?? 0 > $1.postdate ?? 0 })
            case .normal: break
                
            }
            self.topicListModel?.topics=(self.topicListModel?.topics ?? []) + response!.topics
            self.loadPreview(topicListP: response){
                _ in
                self.progressCount += 1
                if(self.progressCount ==  response!.topics.count){
                    self.progressBar.setProgress(1, animated: true)
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut,
                      animations: {self.progressBar.alpha = 0},
                      completion: { _ in self.progressBar.isHidden = true
                        self.progressCount = 0
                        //Do anything else that depends on this animation ending
                    })
                }
            }
            self.topicListTableView.reloadData()
            //Model.topics.
            self.loadFlag = true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openTopic" {
            if let viewController = segue.destination as? TopicController {
                if let cell = sender as? TopicListTableCell, let indexPath = topicListTableView.indexPath(for: cell) {
                    //var affiliation = affiliations[indexPath.row]
                    viewController.topicModelList[1] = Model.topics[cell.tid!]?[1]
                    viewController.replyNum = topicListModel?.topics[indexPath.row].replies
                    viewController.tid = cell.tid
                }
            }
        }
    }
    
    func setOrderButtonTitle(){
        var orderBtnString = ""
        switch order{
        case .normal:
            orderBtnString="默认排序"
            orderImage.image = UIImage(named: "normal")!
        case .replies:
            orderBtnString="回复数量"
            orderImage.image = UIImage(named: "reply")!
            
        case .date:
            orderBtnString="发帖时间"
            orderImage.image = UIImage(named: "new")!
            
        }
        sortButton.setTitle(orderBtnString, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.progressBar.setProgress(0.2, animated: true)
        order = Order(rawValue: UserDefaults.standard.string(forKey: "sortTopic") ?? "normal")!
        if(UserDefaults.standard.array(forKey: "blockedUsers") == nil){
            UserDefaults.standard.set([], forKey: "blockedUsers")
        }
        setOrderButtonTitle()
        topicListTableView.delegate=self
        topicListTableView.dataSource=self
        // Do any additional setup after loading the view.
        topicListTableView.rowHeight = UITableView.automaticDimension
        topicListTableView.estimatedRowHeight = 150
        Model.getTopicList(fid: fid!){
            response in
            if(response == nil){
                self.showAlertAction(title: "错误", message: "载入板块错误")
                return
            }
            self.topicListModel = response
            self.filterBlockedUsers()
            switch self.order{
            case .replies:
                self.topicListModel?.topics.sort(by: { $0.replies ?? 0 > $1.replies ?? 0 })
            case .date:
                self.topicListModel?.topics.sort(by: { $0.postdate ?? 0 > $1.postdate ?? 0 })
            case .normal: break
            }
            
            self.topicListTableView.reloadData()
            self.progressBar.setProgress(0.8, animated: true)
            self.loadPreview(topicListP: response){
                _ in
                self.progressCount += 1
                if(self.progressCount ==  response!.topics.count){
                    self.progressBar.setProgress(1, animated: true)
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut,
                        animations: {self.progressBar.alpha = 0},
                        completion: { _ in self.progressBar.isHidden = true
                        self.progressCount = 0
                            //Do anything else that depends on this animation ending
                        })
                }
            }
        }
        
    }
    //    func loadSubjectAndTag(topicListP:__T?){
    //         if let topicList=topicListP{
    //            for topic in (topicList.topics){
    //                topic.tid = Model.getActulTid(url: topic.tpcurl!)!
    //                (topic.tags,topic.subjectNoTags)=util.getTag(subject: topic.subject!)
    //            }
    //        }
    //    }
    func filterBlockedUsers(){
        let blockList = UserDefaults.standard.array(forKey: "blockedUsers") as! [String]
        var i = 0
        for topic in topicListModel!.topics{
            if blockList.contains(topic.authorid!){
                topicListModel!.topics.remove(at: i)
                i = i - 1
            }
            i = i + 1
        }
    }
    
    func showAlertAction(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadPreview(topicListP:__T?,completion: @escaping (Bool) -> Void){
        if let topicList = topicListP{
            for topic in (topicList.topics){
                topic.tid = Model.getActulTid(url: topic.tpcurl!)!
                Model.loadTopic(tid: topic.tid!){
                    response2 in
                    if(response2){
                        //topic.content=Model.topics[topic.tid!]![1]?.replys[0].content
                        //TODO
                        topic.content = Model.previewString(content: Model.topics[topic.tid!]![1]?.replys[0].content ?? "")
                        topic.score = Model.topics[topic.tid!]![1]?.replys[0].score
                        (topic.tags,topic.subjectNoTags)=util.getTag(subject: topic.subject!)
                        self.topicListTableView.reloadData()
                        let imgLink = util.getImgLink(content: Model.topics[topic.tid!]![1]?.replys[0].content ?? "")
                        if let link = imgLink{
                            if(link.starts(with: ".")){
                                var actualLink="https://img.nga.178.com/attachments"
                                let begin = link.index(link.startIndex, offsetBy: 1)
                                actualLink = actualLink + link[begin..<link.endIndex]
                                Alamofire.request(actualLink).responseData { response in
                                    if let image = response.result.value {
                                        topic.image = image
                                        self.topicListTableView.reloadData()
                                    }
                                }
                            }
                        }
                        completion(true)

                    }else{
                        print("load_topic_error")
                    }
                }
            }
        }else{
            print("error")
        }
    }
    
}


class TopicListTableView: UITableView{
    
}
protocol TopicOptionDelegate:class {
    func showMoreOption(cell:TopicListTableCell)
}

class TopicListTableCell: UITableViewCell{
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var upVote: UILabel!
    @IBOutlet weak var commentNum: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var authorTime: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var topicImage: UIImageView!
    var tagCount = 0
    var tid:Int?
    @IBOutlet weak var moreOptions: UIButton!
    weak var delegate:TopicOptionDelegate?
    @IBAction func moreOptionsAction(_ sender: UIButton) {
        delegate?.showMoreOption(cell: self)
    }
    
}


