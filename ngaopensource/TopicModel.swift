//
//  TopicModel.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/26/19.
//  Copyright © 2019 rongday. All rights reserved.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let topicModel = try? newJSONDecoder().decode(TopicModel.self, from: jsonData)

import Foundation

// MARK: - TopicModel
class TopicModel: Codable {
    let data: DataClass2?
    let encode: String?
    let time: Int?

    init(data: DataClass2?, encode: String?, time: Int?) {
        self.data = data
        self.encode = encode
        self.time = time
    }
}

// MARK: - DataClass
class DataClass2: Codable {
    let cu: Cu?
    let global: Global?
    let u: U?
    let r: [String: R]?
    let t: T?
    let f: F?
    let rRows, rRowsPage, rows, page: Int?

    enum CodingKeys: String, CodingKey {
        case cu = "__CU"
        case global = "__GLOBAL"
        case u = "__U"
        case r = "__R"
        case t = "__T"
        case f = "__F"
        case rRows = "__R__ROWS"
        case rRowsPage = "__R__ROWS_PAGE"
        case rows = "__ROWS"
        case page = "__PAGE"
    }

    init(cu: Cu?, global: Global?, u: U?, r: [String: R]?, t: T?, f: F?, rRows: Int?, rRowsPage: Int?, rows: Int?, page: Int?) {
        self.cu = cu
        self.global = global
        self.u = u
        self.r = r
        self.t = t
        self.f = f
        self.rRows = rRows
        self.rRowsPage = rRowsPage
        self.rows = rows
        self.page = page
    }
}





// MARK: - R
class R: Codable {
    let content, alterinfo: String?
    let tid, score, score2: Int?
    let postdate: String?
    let authorid: Int?
    let subject: String?
    let type, fid, pid, recommend: Int?
    let lou, contentLength: Int?
    let fromClient: String?
    let postdatetimestamp: Int?

    enum CodingKeys: String, CodingKey {
        case content, alterinfo, tid, score
        case score2 = "score_2"
        case postdate, authorid, subject, type, fid, pid, recommend, lou
        case contentLength = "content_length"
        case fromClient = "from_client"
        case postdatetimestamp
    }

    init(content: String?, alterinfo: String?, tid: Int?, score: Int?, score2: Int?, postdate: String?, authorid: Int?, subject: String?, type: Int?, fid: Int?, pid: Int?, recommend: Int?, lou: Int?, contentLength: Int?, fromClient: String?, postdatetimestamp: Int?) {
        self.content = content
        self.alterinfo = alterinfo
        self.tid = tid
        self.score = score
        self.score2 = score2
        self.postdate = postdate
        self.authorid = authorid
        self.subject = subject
        self.type = type
        self.fid = fid
        self.pid = pid
        self.recommend = recommend
        self.lou = lou
        self.contentLength = contentLength
        self.fromClient = fromClient
        self.postdatetimestamp = postdatetimestamp
    }
}



// MARK: - PostMiscVar
class PostMiscVar: Codable {
    let contentLength, fid: Int?
    let fromClient: String?

    enum CodingKeys: String, CodingKey {
        case contentLength = "content_length"
        case fid
        case fromClient = "from_client"
    }

    init(contentLength: Int?, fid: Int?, fromClient: String?) {
        self.contentLength = contentLength
        self.fid = fid
        self.fromClient = fromClient
    }
}

// MARK: - U
class U: Codable {
    let the17182032, the37810885, the42992770: The17182032?
    let groups: [String: [String: Group]]?
    let reputations: Reputations?

    enum CodingKeys: String, CodingKey {
        case the17182032 = "17182032"
        case the37810885 = "37810885"
        case the42992770 = "42992770"
        case groups = "__GROUPS"
        case reputations = "__REPUTATIONS"
    }

    init(the17182032: The17182032?, the37810885: The17182032?, the42992770: The17182032?, groups: [String: [String: Group]]?, reputations: Reputations?) {
        self.the17182032 = the17182032
        self.the37810885 = the37810885
        self.the42992770 = the42992770
        self.groups = groups
        self.reputations = reputations
    }
}

enum Group: Codable {
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
        throw DecodingError.typeMismatch(Group.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Group"))
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

// MARK: - Reputations
class Reputations: Codable {
    let the22: [String: Group]?

    enum CodingKeys: String, CodingKey {
        case the22 = "22"
    }

    init(the22: [String: Group]?) {
        self.the22 = the22
    }
}

// MARK: - The17182032
class The17182032: Codable {
    let uid: Int?
    let username: String?
    let credit: Int?
    let medal, reputation: String?
    let groupid, memberid: Int?
    let avatar: String?
    let yz: Int?
    let site, honor: String?
    let regdate: Int?
    let muteTime: String?
    let postnum, rvrc, money, thisvisit: Int?
    let signature, nickname: String?
    let bitData: Int?

    enum CodingKeys: String, CodingKey {
        case uid, username, credit, medal, reputation, groupid, memberid, avatar, yz, site, honor, regdate
        case muteTime = "mute_time"
        case postnum, rvrc, money, thisvisit, signature, nickname
        case bitData = "bit_data"
    }

    init(uid: Int?, username: String?, credit: Int?, medal: String?, reputation: String?, groupid: Int?, memberid: Int?, avatar: String?, yz: Int?, site: String?, honor: String?, regdate: Int?, muteTime: String?, postnum: Int?, rvrc: Int?, money: Int?, thisvisit: Int?, signature: String?, nickname: String?, bitData: Int?) {
        self.uid = uid
        self.username = username
        self.credit = credit
        self.medal = medal
        self.reputation = reputation
        self.groupid = groupid
        self.memberid = memberid
        self.avatar = avatar
        self.yz = yz
        self.site = site
        self.honor = honor
        self.regdate = regdate
        self.muteTime = muteTime
        self.postnum = postnum
        self.rvrc = rvrc
        self.money = money
        self.thisvisit = thisvisit
        self.signature = signature
        self.nickname = nickname
        self.bitData = bitData
    }
}
