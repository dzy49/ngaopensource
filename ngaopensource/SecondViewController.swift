//
//  SecondViewController.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/21/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    let tid=9268613
    override func viewDidLoad() {
        super.viewDidLoad()
       
}
    @IBOutlet weak var bla: UITextView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openTopic2" {
            if let viewController = segue.destination as? TopicController {
                
                    //var affiliation = affiliations[indexPath.row]
                    viewController.topicModelList[1] = Model.topics[tid]?[1]
                    viewController.replyNum = 100
                    viewController.tid = tid
                
            }
        }
    }

}

