//
//  util.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/27/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import Foundation
import UIKit
class util{
    let lightyellow:UIColor=#colorLiteral(red: 0.9972997308, green: 0.9770990014, blue: 0.9307858348, alpha: 1)
    let darkeryellow:UIColor=#colorLiteral(red: 0.9914044738, green: 0.9538459182, blue: 0.8533558249, alpha: 1)
    
    static func getTag(subject:String)->([String],String){
        var subjectNoTag=subject
        let regexp = "\\[([^]]+)\\]"
        // let regexp = "(<__R>[\\s\\S]*<\\/__R>)"
        var results:[String]=[]
        var range = subject.range(of:regexp, options: .regularExpression)
        while(range != nil){
            let result = subjectNoTag[range!]
            results.append(String(result))
            subjectNoTag.removeSubrange(range!)
            range=subjectNoTag.range(of:regexp, options: .regularExpression)
            }
        return (results,subjectNoTag)
        }
            
        
    }

