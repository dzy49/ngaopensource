//
//  SavedTopicsController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 2/17/20.
//  Copyright © 2020 rongday. All rights reserved.
//

import Foundation
import UIKit
import XLActionController

class SavedTopic:NSObject, NSCoding, Codable{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(topic, forKey: "topic")
        aCoder.encode(savedTime, forKey: "savedTime")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let topic = aDecoder.decodeObject(forKey: "topic") as! Topic
        let savedTime = aDecoder.decodeObject(forKey: "savedTime") as! Data
        self.init(topic: topic, savedTime: savedTime)
    }
    
    var topic:Topic?
    var savedTime:Data?
    init(topic:Topic, savedTime:Data){
        self.topic = topic
        self.savedTime = savedTime
    }
}

class SavedTopicController: UIViewController,UITableViewDelegate,UITableViewDataSource, TopicOptionDelegate{
    func showMoreOption(cell: TopicListTableCell) {
        let actionSheet = SortActionController()
        // set up a header title
        
        actionSheet.headerData = nil
        guard let indexPath = self.topicListTableView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        // Add some actions, note that the first parameter of `Action` initializer is `ActionData`.
        
        actionSheet.addAction(Action(ActionData(title: "移除", subtitle: "", image: UIImage(named: "new")!), style: .default, handler: { action in
            //print(indexPath.row)
            self.savedTopics?.remove(at: indexPath.row)
            if let data = UserDefaults.standard.object(forKey: "savedTopics") as? Data{
                var saved = try? PropertyListDecoder().decode([SavedTopic].self, from: data)
                saved?.remove(at: indexPath.row)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(saved), forKey: "savedTopics")
            }
            self.topicListTableView.reloadData()
        }))
      
        // present actionSheet like any other view controller
        present(actionSheet, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openSavedTopic" {
            if let viewController = segue.destination as? TopicController {
                if let cell = sender as? TopicListTableCell, let indexPath = topicListTableView.indexPath(for: cell) {
                    viewController.topicModelList[1] = Model.topics[cell.tid!]?[1]
                    viewController.replyNum = savedTopics?[indexPath.row].topic?.replies
                    viewController.tid = cell.tid
                }
            }
        }
    }
    
    
    
    var savedTopics:[SavedTopic]?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTopics?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topicListTableView.dequeueReusableCell(withIdentifier: "TopicListTableCell", for: indexPath)
        if let myCell =  cell as? TopicListTableCell {
            myCell.delegate = self
            if let topics = savedTopics{
                if let t = topics[indexPath.row].topic{
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
                    if indexPath.row%2 == 1{
                        myCell.background.backgroundColor = UIColor(named: "lightYellow")
                        //util().lightyellow
                    }else{
                        myCell.background.backgroundColor =  UIColor(named: "darkYellow")
                    }
                }
            }
        }
        
        
        return cell
    }
    
    override func viewDidLoad() {
        topicListTableView.delegate=self
        topicListTableView.dataSource=self
        //savedTopics = UserDefaults.standard.array(forKey: "savedTopics") as? [SavedTopic]
//        do{
//            let decoded  = UserDefaults.standard.object(forKey: "savedTopics") as! Data
//            savedTopics  = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? [SavedTopic]
//
//        }catch{
//            print("error encoding data")
//        }
        
        if let data = UserDefaults.standard.object(forKey: "savedTopics") as? Data{
            savedTopics = try? PropertyListDecoder().decode([SavedTopic].self, from: data)
        }
        topicListTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let data = UserDefaults.standard.object(forKey: "savedTopics") as? Data{
            savedTopics = try? PropertyListDecoder().decode([SavedTopic].self, from: data)
        }
        topicListTableView.reloadData()
    }
    @IBOutlet weak var topicListTableView: TopicListTableView!
}
