//
//  TopicController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/29/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class TopicController:ButtonBarPagerTabStripViewController{
    var replyNum:Int?
    var topicModel:__R?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var pages:[UIViewController] = []
        var pageNum:Int = 1
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
            child_1.info = String(i) ?? ""
            pages.append(child_1)
        }
        return pages
    }
    
}
class ReplyController:UIViewController,IndicatorInfoProvider{
    var info=""
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: info)
    }
    override func viewDidLoad() {
        label.text=info
    }
    @IBOutlet weak var label: UILabel!
    
}
