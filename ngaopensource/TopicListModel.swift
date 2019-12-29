//
//  TopicListModel.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/25/19.
//  Copyright © 2019 rongday. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let topicListModel = try? newJSONDecoder().decode(TopicListModel.self, from: jsonData)

import Foundation

// MARK: - TopicListModel
class TopicListModel: Codable {
    let data: DataClass?
    let encode: String?
    let time: Int?

    init(data: DataClass?, encode: String?, time: Int?) {
        self.data = data
        self.encode = encode
        self.time = time
    }
}

// MARK: - DataClass
class DataClass: Codable {
    let cu: Cu?
    let global: Global?
    let f: F?
    let rows: Int?
    let t: [String: T]?
    let tRows, tRowsPage, rRowsPage: Int?

    enum CodingKeys: String, CodingKey {
        case cu = "__CU"
        case global = "__GLOBAL"
        case f = "__F"
        case rows = "__ROWS"
        case t = "__T"
        case tRows = "__T__ROWS"
        case tRowsPage = "__T__ROWS_PAGE"
        case rRowsPage = "__R__ROWS_PAGE"
    }

    init(cu: Cu?, global: Global?, f: F?, rows: Int?, t: [String: T]?, tRows: Int?, tRowsPage: Int?, rRowsPage: Int?) {
        self.cu = cu
        self.global = global
        self.f = f
        self.rows = rows
        self.t = t
        self.tRows = tRows
        self.tRowsPage = tRowsPage
        self.rRowsPage = rRowsPage
    }
}

// MARK: - Cu
class Cu: Codable {
    let uid, groupBit, admincheck, rvrc: Int?

    enum CodingKeys: String, CodingKey {
        case uid
        case groupBit = "group_bit"
        case admincheck, rvrc
    }

    init(uid: Int?, groupBit: Int?, admincheck: Int?, rvrc: Int?) {
        self.uid = uid
        self.groupBit = groupBit
        self.admincheck = admincheck
        self.rvrc = rvrc
    }
}

// MARK: - F
class F: Codable {
    let toppedTopic: Int?
    let subForums: [String: [String: SubForum]]?
    let selectedForum: String?
    let fid: Int?
    let unionForum, unionForumDefault: String?

    enum CodingKeys: String, CodingKey {
        case toppedTopic = "topped_topic"
        case subForums = "sub_forums"
        case selectedForum = "__SELECTED_FORUM"
        case fid
        case unionForum = "__UNION_FORUM"
        case unionForumDefault = "__UNION_FORUM_DEFAULT"
    }

    init(toppedTopic: Int?, subForums: [String: [String: SubForum]]?, selectedForum: String?, fid: Int?, unionForum: String?, unionForumDefault: String?) {
        self.toppedTopic = toppedTopic
        self.subForums = subForums
        self.selectedForum = selectedForum
        self.fid = fid
        self.unionForum = unionForum
        self.unionForumDefault = unionForumDefault
    }
}

enum SubForum: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(SubForum.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SubForum"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - Global
class Global: Codable {
    let attachBaseView: String?

    enum CodingKeys: String, CodingKey {
        case attachBaseView = "_ATTACH_BASE_VIEW"
    }

    init(attachBaseView: String?) {
        self.attachBaseView = attachBaseView
    }
}

// MARK: - T
class T: Codable {
    let tid, fid, quoteFrom: Int?
    let quoteTo: String?
    let icon: Int?
    let topicMisc, author: String?
    let authorid: Int?
    let subject: String?
    let type, postdate, lastpost: Int?
    let lastposter: String?
    let replies, lastmodify, recommend: Int?
    let tpcurl, titlefont: String?
    let topicMiscVar: [String: Int]?
    let parent: [String: SubForum]?
    var content:String?
    //var score:Int?
    
    enum CodingKeys: String, CodingKey {
        case tid, fid
        case quoteFrom = "quote_from"
        case quoteTo = "quote_to"
        case icon
        case topicMisc = "topic_misc"
        case author, authorid, subject, type, postdate, lastpost, lastposter, replies, lastmodify, recommend, tpcurl, titlefont
        case topicMiscVar = "topic_misc_var"
        case parent
    }

    init(tid: Int?, fid: Int?, quoteFrom: Int?, quoteTo: String?, icon: Int?, topicMisc: String?, author: String?, authorid: Int?, subject: String?, type: Int?, postdate: Int?, lastpost: Int?, lastposter: String?, replies: Int?, lastmodify: Int?, recommend: Int?, tpcurl: String?, titlefont: String?, topicMiscVar: [String: Int]?, parent: [String: SubForum]?,content:String?) {
        self.tid = tid
        self.fid = fid
        self.quoteFrom = quoteFrom
        self.quoteTo = quoteTo
        self.icon = icon
        self.topicMisc = topicMisc
        self.author = author
        self.authorid = authorid
        self.subject = subject
        self.type = type
        self.postdate = postdate
        self.lastpost = lastpost
        self.lastposter = lastposter
        self.replies = replies
        self.lastmodify = lastmodify
        self.recommend = recommend
        self.tpcurl = tpcurl
        self.titlefont = titlefont
        self.topicMiscVar = topicMiscVar
        self.parent = parent
        self.content = content
        //self.score = score
    }
}
