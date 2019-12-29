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

class TopicListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var topicListTableView: TopicListTableView!
    var topicListModel:__T?
    var model = Model()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model=topicListModel{
            return model.topics.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topicListTableView.dequeueReusableCell(withIdentifier: "TopicListTableCell", for: indexPath)
        if let myCell =  cell as? TopicListTableCell {
            if let model = topicListModel{
                let t = model.topics[(indexPath.row)]
                if let subject = t.subjectNoTags{
                   // let (tags,title) = util().getTag(subject: subject)
                    myCell.subject.text = subject
                    myCell.tagList.removeAllTags()
                    if let tags=t.tags{
                        if(tags.count != 0){
                            myCell.tagList.addTags(tags)
                        }
                    }
                }
                myCell.tid=t.tid
                myCell.content.text = t.content
                myCell.authorTime.text = t.author
                if let replynum = t.replies{
                    myCell.commentNum.text = String(replynum)
                }
                if let upvoteNum = t.score{
                    myCell.upVote.text = String(upvoteNum)
                }
                if indexPath.row%2 == 1{
                    myCell.background.backgroundColor = util().lightyellow
                }else{
                    myCell.background.backgroundColor = util().darkeryellow
                }
                
            }
        }
        
        return cell
        //return UITableViewCell()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openTopic" {
            if let viewController = segue.destination as? TopicController {
                if let cell = sender as? TopicListTableCell, let indexPath = topicListTableView.indexPath(for: cell) {
                    //var affiliation = affiliations[indexPath.row]
                    viewController.topicModel = model.topics[cell.tid!]
                    viewController.replyNum = topicListModel?.topics[indexPath.row].replies
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicListTableView.delegate=self
        topicListTableView.dataSource=self
        // Do any additional setup after loading the view.
        topicListTableView.rowHeight = UITableView.automaticDimension
        topicListTableView.estimatedRowHeight = 150
        model.setCookie(key:"ngaPassportUid",value:"19000089")
        model.setCookie(key:"ngaPassportCid",value:"X8t7fgkv3l5e5vv6moeqhmhm9c8mevhg2cjcmjv0")
        model.getTopicList(fid: -152678){
            response in
            self.topicListModel=response
            DispatchQueue.main.async{
                self.topicListTableView.reloadData()
            }
          
            if let topicList=self.topicListModel{
                for topic in (topicList.topics){
                    topic.tid = self.model.getActulTid(url: topic.tpcurl!)!
                    self.model.loadTopic(tid: topic.tid!){
                        response2 in
                        if(response2){
                            topic.content=self.model.topics[topic.tid!]!.replys[0].content
                            //topic.value.score=response2?.replys[0].score
                            topic.score=self.model.topics[topic.tid!]!.replys[0].score
                            (topic.tags,topic.subjectNoTags)=util.getTag(subject: topic.subject!)
                           
                            self.topicListTableView.reloadData()
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
    
}


class TopicListTableView: UITableView{
    
}

class TopicListTableCell: UITableViewCell{
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var upVote: UILabel!
    @IBOutlet weak var commentNum: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var authorTime: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var tagList: TagListView!
    var tagCount = 0
    var tid:Int?
}

