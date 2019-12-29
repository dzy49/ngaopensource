//
//  forumModels.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/27/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import Foundation
class __T:Codable{
    let topics:[Topic]
    enum CodingKeys: String, CodingKey {
        case topics = "item"
    }
}

class Parent:Codable{
    let forums:[SubForum]?
    enum CodingKeys: String, CodingKey {
        case forums = "item"
    }
}

class TopicMiscVar:Codable{
    let forums:ArrOrSubForum?
    enum CodingKeys: String, CodingKey {
        case forums = "item"
    }
}

enum ArrOrSubForum:Codable{
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            // First try to decode as a Dog, if this fails then try another
            self = try .arr(container.decode([SubForum].self))
        } catch {
            do {
                // Try to decode as a Turtle, if this fails too, you have a type mismatch
                self = try .subForum(container.decode(SubForum.self))
            } catch {
                // throw type mismatch error
                throw DecodingError.typeMismatch(ArrOrSubForum.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload conflicts with expected type, (Dog or Turtle)") )
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
               switch self {
               case .arr(let arr):
                   try container.encode(arr)
               case .subForum(let subForum):
                   try container.encode(subForum)
               }
           
    }
    
    case arr([SubForum]?)
    case subForum(SubForum?)
}
class Topic:Codable{
    var tid: Int?
    let fid, quoteFrom: Int?
    let quoteTo: String?
    let icon: Int?
    let topicMisc, author: String?
    let authorid: Int?
    let subject: String?
    let type, postdate, lastpost: Int?
    let lastposter: String?
    let replies, lastmodify, recommend: Int?
    let tpcurl, titlefont: String?
    let topicMiscVar: TopicMiscVar?
    let parent: Parent?
    var content:String?
    var score:Int?
    var tags:[String]?
    var subjectNoTags:String?
    
    enum CodingKeys: String, CodingKey {
        case tid, fid
        case quoteFrom = "quote_from"
        case quoteTo = "quote_to"
        case icon
        case topicMisc = "topic_misc"
        case author, authorid, subject, type, postdate, lastpost, lastposter, replies, lastmodify, recommend, tpcurl, titlefont
        case topicMiscVar = "topic_misc_var"
        case parent
        case content
        case score
        case tags
        case subjectNoTags
    }

    
    
}
