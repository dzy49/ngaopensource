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

class AttributedString : Codable {
    
    var attributedString : NSAttributedString
    
    init(nsAttributedString : NSAttributedString) {
        self.attributedString = nsAttributedString
    }
    public required init(from decoder: Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        guard let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(singleContainer.decode(Data.self)) as? NSAttributedString
            else { throw DecodingError.dataCorruptedError(in: singleContainer, debugDescription: "Data is corrupted") }
        self.attributedString = attributedString }
    func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        try singleContainer.encode(NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false))
    }
}

class __R:Codable{
    var converted:Bool = false
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
    var attrContent:AttributedString?
    var height:CGFloat?
}

class Model{
    // let cookie = HTTPCookie.init()
    //let key=HTTPCookiePropertyKey.init("ngaPassportUid")
    
    
    static let URL = "nga.178.com"
    static let ExpTime = TimeInterval(60 * 60 * 24 * 365)
    static var topics:[Int : [Int : __R]] = [ : ]
    static func setCookie(key: String, value: Any) {
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
    
    static func getLogin(){
        Alamofire.request("https://www.ngbcdn.com/getLogin")
            .responseJSON { response in
                if let json = response.result.value as? [String:Any] {
                    if let data = json["data"] as? [String:Any]{
                        Model.setCookie(key:"ngaPassportUid",value:data["uid"])
                        Model.setCookie(key:"ngaPassportCid",value:data["cid"])
                    }
                }
        }
    }
    
    static func getUrl(){
        
    }
    
    static func getTopicList(fid:Int,page:Int = 1,completion: @escaping (__T?) -> Void){
        var url = "https://nga.178.com/thread.php?"
        url=url+"fid="+String(fid)+"&page="+String(page)
        //-152678
        Alamofire.request(url, parameters: ["lite": "xml"])
            .response { response in
                //print(response)
                let strXML = Model.self.gbkdecode(data: response.data!)
                // let data = strXML?.data(using: String.Encoding.unicode)
                let topicStr=Model.self.getSection(str: strXML ?? "",header:"__T")
                //let topicStr=""
                
                //TODO NIL
                if let topicString = topicStr{
                    
                    let data2 = topicString.data(using: String.Encoding.unicode)
                    var T:__T?
                    do{
                        T = try XMLDecoder().decode(__T.self, from: data2!)
                    }catch{
                        print(error)
                        T = nil
                    }
                    completion(T)
                    
                }else{
                    completion(nil)
                }
                //print(topicListModel)
                
        }
    }
    
    static func loadTopic(tid:Int,page:Int = 1,save:Bool=false,completion: @escaping (Bool) -> Void){
        var url = "https://nga.178.com/read.php?"
        url = url + "tid=" + String(tid)
        url = url + "&page=" + String(page)
        
        Alamofire.request(url, parameters: ["lite": "xml"])
            .response { response in
                
                let strXML=self.gbkdecodeXML(data: response.data!)
                if let replyStr=self.getSection(str: strXML ?? "",header:"__R"){
                    let data2 = replyStr.data(using: String.Encoding.unicode)
                    let R = try? XMLDecoder().decode(__R.self, from: data2!)
                    
                    if let _ = Model.self.topics[tid]{
                        Model.self.topics[tid]![page] = R
                    }else{
                        var topicPage:[Int:__R] = [:]
                        topicPage[page]=R
                        Model.self.topics[tid] = topicPage
                    }
                    
                    //TODO nil?
                    //print(topicListModel)
                    completion(true)
                }else{
                    completion(false)
                }
        }
    }
    static func getTopic(fid:Int,completion: @escaping (__R?) -> Void){
        var url = "https://nga.178.com/read.php?"
        url=url+"tid="+String(fid)
        //print(url)
        Alamofire.request(url, parameters: ["lite": "xml"])
            .response { response in
                // let strJSON=Model.self.gbkdecode(data: response.data!)
                
                //let data = strJSON?.data(using: String.Encoding.unicode)
                // let topicModel = try? JSONDecoder().decode(TopicModel.self, from: data!)
                
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
        return Model.topics[tid]?[1]
    }
    
    
    static func gbkdecode(data:Data)->String?{
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let str = String(data: data, encoding: String.Encoding(rawValue: enc))
        //print(str as Any)
        let strJSON=str?.replacingOccurrences(of: "window.script_muti_get_var_store=", with: "")
        return strJSON
    }
    
    static func gbkdecodeXML(data:Data)->String?{
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let str = String(data: data, encoding: String.Encoding(rawValue: enc))
        //print(str as Any)
        
        return str
    }
    
    static func getSection(str:String,header:String)->String?{
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
    static func getActulTid(url:String)->Int?{
        let regexp = "\\d+"
        // let regexp = "(<__R>[\\s\\S]*<\\/__R>)"
        if let range = url.range(of:regexp, options: .regularExpression) {
            let result = url.substring(with:range)
            //print(result)
            return Int(result)
        }
        return nil
    }
    
    static func getAttributedString(content:String?)->NSAttributedString{
        if let str = content{
            //bug
            // let str2="\t"+str+"\n"
            let attrStr = try! NSAttributedString(
                data: ((str.data(using: String.Encoding.unicode, allowLossyConversion: true)!)),
                options: [.documentType : NSAttributedString.DocumentType.html],
                documentAttributes: nil)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.headIndent = 12
            paragraphStyle.tailIndent = -12
            //paragraphStyle.paragraphSpacingBefore = 25
            // Note that setting paragraphStyle.firstLineHeadIndent
            // doesn't use the background color for the first line's
            // indentation. Use a tab stop on the first line instead.
            paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: paragraphStyle.headIndent, options: [:])]
            let mut = NSMutableAttributedString(attributedString:attrStr)
            
            
            
            var offset=0
            let imgs = util.getImgRange(content: mut.mutableString as String)
            for range in imgs{
                let lastRange=NSRange(location: range.upperBound-6+offset, length: 6)
                mut.mutableString.deleteCharacters(in: lastRange)
                let firstRange=NSRange(location: range.lowerBound+offset, length: 5)
                mut.mutableString.deleteCharacters(in: firstRange)
                
                let offsetedRange=NSRange(location: range.lowerBound+offset, length: range.length-11)
                let imgLink = mut.mutableString.substring(with: offsetedRange)
                var placeHolderImg:UIImage?
                if imgs.count >= 8 {
                    placeHolderImg = UIImage(named: "placeHolderImgSmall")!
                }else{
                    placeHolderImg = UIImage(named: "LoadingImgPlaceHolder")!
                }
                //let placeHolderImgAttrString = NSMutableAttributedString()
                let placeHolderImgAttach = NSTextAttachment(image: placeHolderImg!)
                let placeHolderImgAttrString = NSAttributedString(attachment: placeHolderImgAttach).mutableCopy() as! NSMutableAttributedString
                placeHolderImgAttrString.addAttribute(.imagePath, value: imgLink, range:NSMakeRange(0, placeHolderImgAttrString.length))
                // let num=mut.mutableString.replaceOccurrences(of: "\n", with: "\n\u{2000}\u{2000}", options:[], range: offsetedRange)
                mut.replaceCharacters(in: offsetedRange, with: placeHolderImgAttrString)
                //mut.mutableString.insert("\u{2000}\u{2000}", at: offsetedRange.lowerBound)
                //mut.mutableString.insert("\n\n", at: offsetedRange.upperBound+2+2*num
                offset=offset-offsetedRange.length+placeHolderImgAttrString.length-11
            }
            
            let quotes=util.getQuoteRange(content: mut.mutableString as String)
            //print(mut.mutableString)
            offset=0
            //print(mut.mutableString.length)
            for range in quotes{
                let lastRange=NSRange(location: range.upperBound-8+offset, length: 8)
                mut.mutableString.deleteCharacters(in: lastRange)
                let firstRange=NSRange(location: range.lowerBound+offset, length: 7)
                mut.mutableString.deleteCharacters(in: firstRange)
                
                let offsetedRange=NSRange(location: range.lowerBound+offset, length: range.length-15)
                let num=mut.mutableString.replaceOccurrences(of: "\n", with: "\n\u{2000}\u{2000}", options:[], range: offsetedRange)
                mut.mutableString.insert("\u{2000}\u{2000}", at: offsetedRange.lowerBound)
                mut.mutableString.insert("\n\n", at: offsetedRange.upperBound+2+2*num)
                offset=offset+4+2*num
                let newRange=NSRange(location: offsetedRange.location, length: offsetedRange.length+4+2*num)
                //    print(newRange.upperBound)
                //    print(mut.mutableString.length)
                mut.addAttribute(.paragraphStyle, value: paragraphStyle, range: newRange)
                mut.addAttribute(.backgroundColor, value:UIColor(named: "quoteColor"), range: newRange)
                mut.addAttribute(.baselineOffset, value: -16, range: newRange)
                offset=offset-15
            }
            let colorRanges=util.fontColorRange(content: mut)
             if imgs.count >= 8 {
                return mut
             }else{
                return mut.attributedStringWithResizedImages()
            }
            
        }else{
            return NSAttributedString(string: "")
        }
    }
    
    static func previewString(content:String)->String{
        var preview = content.replacingOccurrences(of: "<br/>", with: " ")
        preview = preview.replacingOccurrences(of: #"\[img\](.*)\[/img\]"#, with: " ", options: .regularExpression)
        preview = preview.replacingOccurrences(of: #"\[s:ac:(.*)\]"#, with: " ", options: .regularExpression)
        return preview
    }
    
    static func loadImg(str:NSMutableAttributedString, completion: @escaping (NSMutableAttributedString) -> Void){
        let text = str
        var imgLinkArr:[String] = []
        /*text.enumerateAttribute(.imagePath, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let link = value as? String {
                imgLinkArr.append(link)
            }
        })*/
        text.enumerateAttributes(in: NSRange(location: 0, length: text.length)) { (attributes, range, stop) in
            attributes.forEach { (key, value) in
                switch key {
                case NSAttributedString.Key.imagePath:
                    if let link = value as? String {
                        imgLinkArr.append(link)
                    }
                default: break
                }
            }
        }
        
        var count = 0
        var loadCount = 0
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let _ = value as? NSTextAttachment {
                if(count >= imgLinkArr.count){
                    return
                }
                var link = ""
                if(imgLinkArr[count].starts(with: ".")){
                    link = "https://img.nga.178.com/attachments" + imgLinkArr[count].dropFirst()
                }else{
                    link = imgLinkArr[count]
                }
                Alamofire.request(link, method: .get).responseImage { response in
                    loadCount += 1
                    guard let image = response.result.value else {
                        return
                    }
                    let screenSize: CGRect = UIScreen.main.bounds
                    var newImage = image
                    var inquote = false
                    if image.size.width > screenSize.width/5 {
                        text.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: range, options: .init(rawValue: 0), using: { (value, range, stop) in
                            if let _ = value as? NSParagraphStyle{
                                newImage = image.resizeImage(scale: (screenSize.width-45)/image.size.width)
                                inquote = true
                            }
                        })
                        if(!inquote){
                            newImage = image.resizeImage(scale: (screenSize.width-12)/image.size.width)
                        }
                    }
                    let attachment = NSTextAttachment()
                    attachment.image = newImage
                    text.removeAttribute(.attachment, range: range)
                    text.addAttribute(NSAttributedString.Key.attachment, value: attachment, range: range)
                    if(loadCount == imgLinkArr.count){
                        completion(text)
                        return
                    }
                }
                count += 1
            }
        })
    }
    
    static func loadAttrString(tid:Int, pageNum:Int, withPHImg:Bool = true, completion: @escaping (Bool) -> Void){
        for (index, reply) in Model.topics[tid]![pageNum]!.replys.enumerated(){
            var converted = reply.content
            if !withPHImg{
                converted = converted?.replacingOccurrences(of: "[img].", with: "<img src=\"https://img.nga.178.com/attachments")
                converted=converted?.replacingOccurrences(of: "[/img]", with: "\"/>")
                converted=converted?.replacingOccurrences(of: "[img]", with: "<img src=\"")
            }
            converted = converted?.replacingOccurrences(of: "[b]", with: "<b>")
            converted=converted?.replacingOccurrences(of: "[/b]", with: "</b>")
            converted=converted?.replacingOccurrences(of: #"\[color=(.*?)]([\s\S]*?)\[\/color\]"#, with: "<font color=\"$1\">$2</font>", options: .regularExpression)
            converted=converted?.replacingOccurrences(of: "[/del]", with: "</s>")
            converted=converted?.replacingOccurrences(of: "[del]", with: "<s>")
            
            converted=converted?.replacingOccurrences(of: #"\[url=(.*?)]([\s\S]*?)\[\/url\]"#, with: "<a href=\"$1\">$2</a>", options: .regularExpression)
            //?
            converted=converted?.replacingOccurrences(of: #"\[url\]([\s\S]*?)\[\/url\]"#, with: "<a href=\"$1\">$1</a>", options: .regularExpression)
            converted=converted?.replacingOccurrences(of: "[/table]", with: "</tbody></table>")
            converted=converted?.replacingOccurrences(of: "[table]", with: "<table border=\"1\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\"><tbody>")
            converted=converted?.replacingOccurrences(of: "[/tr]", with: "</tr>")
            converted=converted?.replacingOccurrences(of: #"(<br\/>)?\[tr\](<br\/>)?"#, with: "<tr>", options: .regularExpression)
            converted=converted?.replacingOccurrences(of: #"\[td colspan=(\d*)\]"#, with: "<td colspan=\"$1%\">", options: .regularExpression)
            converted=converted?.replacingOccurrences(of: "[align=center]", with: "")
            converted=converted?.replacingOccurrences(of: "[/align]", with: "")
            converted=converted?.replacingOccurrences(of: "[/td]<br/>", with: "</td>")
            converted=converted?.replacingOccurrences(of: "[/td]", with: "</td>")
            
            converted=converted?.replacingOccurrences(of: "[td]", with: "<td>")
            converted=converted?.replacingOccurrences(of: #"\[td(\d+)\]"#, with: "<td width=\"$1%\">", options: .regularExpression)
            converted=util.fontSize(content:converted ?? "")
            // converted=converted?.replacingOccurrences(of: "<br/>", with: "<br/>\u{2000}\u{2000}")
            //converted=converted?.replacingOccurrences(of: "[quote]", with: "<blockquote style=\"padding:12px;background: #f5f5fb;\"")
            // converted=converted?.replacingOccurrences(of: "[quote]", with: "<blockquote style=\"display: block;border-width: 2px 0;border-style: solid;border-color: #eee;background: #eee;padding: 12.0px 12.0px 12.0px;margin: 1.5em 0;position: relative;\"")
            // converted=converted?.replacingOccurrences(of: "[/quote]", with: "</blockquote>")
            // converted = "\u{2000}\u{2000}"+(converted ?? "")+"<br/><br/>"
            converted=String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: 14.5\">%@</span>", converted ?? "")
            
            reply.attrContent = AttributedString(nsAttributedString: self.getAttributedString(content: converted ?? ""))
            let screenWidth: CGFloat = UIScreen.main.bounds.width
            
            //reply.height
            //let attributedString = self.textView.attributedText
            let rect = reply.attrContent?.attributedString.boundingRect(with: CGSize(width: screenWidth-16, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            var titleHeight = CGFloat(0.0)
            if(index == 0 && pageNum == 1){
                let frame = NSString(string: reply.subject ?? "").boundingRect(
                    with: CGSize(width: screenWidth-16, height: .infinity),
                    options: [.usesFontLeading, .usesLineFragmentOrigin],
                    attributes: [.font : UIFont.systemFont(ofSize: 18)],
                    context: nil)
                titleHeight = frame.size.height
            }
            reply.height = (rect?.height ?? 0) + 100 + titleHeight
            //print(reply.height)
        }
        Model.topics[tid]![pageNum]!.converted = true
        completion(true)
    }
}

extension NSAttributedString.Key {
    static let imagePath = NSAttributedString.Key(rawValue: "imagePath")
}
