//
//  model.swift
//  ngaopensource
//
//  Created by Zhaoyuan Deng on 12/24/19.
//  Copyright © 2019 rongday. All rights reserved.
//

import Foundation
import Alamofire
import XMLParsing

class __R:Codable{
    var replys:[Replys]
    enum CodingKeys: String, CodingKey {
        case replys = "item"
    }
}

class Replys:Codable{
    var content:String?
    var alterinfo:String?
    var tid:Int?
    var score:Int?
    var score_2:Int?
    var postdate:String?
    var authorid:Int?
    var subject:String?
    var type:Int?
    var fid:Int?
    var pid:Int?
    var recommend:Int?
    var lou:Int?
    var content_length:Int?
    var postdatetimestamp:Int?
}

class Model{
    // let cookie = HTTPCookie.init()
    //let key=HTTPCookiePropertyKey.init("ngaPassportUid")
    
    
    let URL = "nga.178.com"
    let ExpTime = TimeInterval(60 * 60 * 24 * 365)
    var topics:[Int:__R]=[:]
    func setCookie(key: String, value: Any) {
        let cookieProps = [
            HTTPCookiePropertyKey.domain: URL,
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: ExpTime)
            ] as [HTTPCookiePropertyKey : Any]
        
        let cookie = HTTPCookie(properties: cookieProps)
        
        HTTPCookieStorage.shared.setCookie(cookie!)
    }
    
    func getTopicList(fid:Int,completion: @escaping (__T?) -> Void){
        var url = "https://nga.178.com/thread.php?"
        url=url+"fid="+String(fid)
        //-152678
        Alamofire.request(url, parameters: ["lite": "xml"])
            .response { response in
                //print(response)
                let strXML=self.gbkdecode(data: response.data!)
                let data = strXML?.data(using: String.Encoding.unicode)
              let topicStr=self.getSection(str: strXML!,header:"__T")
                //let topicStr=""
               
 
                let data2 = topicStr!.data(using: String.Encoding.unicode)
                var T:__T?
                do{
                    T = try XMLDecoder().decode(__T.self, from: data2!)
                }catch{
                    print(error)
                    T = nil
                }
                //print(topicListModel)
                completion(T)
        }
    }
    
    func loadTopic(tid:Int,completion: @escaping (Bool) -> Void){
        var url = "https://nga.178.com/read.php?"
               url=url+"tid="+String(tid)
               //print(url)
               Alamofire.request(url, parameters: ["lite": "xml"])
                   .response { response in
                       let strJSON=self.gbkdecode(data: response.data!)
                       
                       let data = strJSON?.data(using: String.Encoding.unicode)
                       let topicModel = try? JSONDecoder().decode(TopicModel.self, from: data!)
                       
                       let strXML=self.gbkdecodeXML(data: response.data!)
                       if let replyStr=self.getSection(str: strXML!,header:"__R"){
                           let data2 = replyStr.data(using: String.Encoding.unicode)
                           let R = try? XMLDecoder().decode(__R.self, from: data2!)
                        self.topics[tid]=R
                       //TODO nil?
                       //print(topicListModel)
                           completion(true)
                       }else{
                           completion(false)
                       }
               }
    }
    func getTopic(fid:Int,completion: @escaping (__R?) -> Void){
        var url = "https://nga.178.com/read.php?"
        url=url+"tid="+String(fid)
        //print(url)
        Alamofire.request(url, parameters: ["lite": "xml"])
            .response { response in
                let strJSON=self.gbkdecode(data: response.data!)
                
                let data = strJSON?.data(using: String.Encoding.unicode)
                let topicModel = try? JSONDecoder().decode(TopicModel.self, from: data!)
                
                let strXML=self.gbkdecodeXML(data: response.data!)
                if let replyStr=self.getSection(str: strXML!,header:"__R"){
                    let data2 = replyStr.data(using: String.Encoding.unicode)
                    let R = try? XMLDecoder().decode(__R.self, from: data2!)
                //TODO nil?
                //print(topicListModel)
                    completion(R)
                }else{
                    completion(nil)
                }
        }
    }
    
    func getTopicMainFloor(tid:Int)->__R?{
        return topics[tid]
    }
    
    
    func gbkdecode(data:Data)->String?{
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let str = String(data: data, encoding: String.Encoding(rawValue: enc))
        //print(str as Any)
        let strJSON=str?.replacingOccurrences(of: "window.script_muti_get_var_store=", with: "")
        return strJSON
    }
    
    func gbkdecodeXML(data:Data)->String?{
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let str = String(data: data, encoding: String.Encoding(rawValue: enc))
        //print(str as Any)
        
        return str
    }
    
    func getSection(str:String,header:String)->String?{
        let regexp = "(<"+header+">[\\s\\S]*<\\/"+header+">)"
        // let regexp = "(<__R>[\\s\\S]*<\\/__R>)"
        if let range = str.range(of:regexp, options: .regularExpression) {
            let result = str.substring(with:range)
            //print(result)
            return result
        }
        return nil
    }
    
    //get tid from url because tid maybe wrong from API
    func getActulTid(url:String)->Int?{
        let regexp = "\\d+"
        // let regexp = "(<__R>[\\s\\S]*<\\/__R>)"
        if let range = url.range(of:regexp, options: .regularExpression) {
            let result = url.substring(with:range)
            //print(result)
            return Int(result)
        }
        return nil
    }
}
