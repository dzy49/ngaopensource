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
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let fontsize = 14.0
    let lightyellow:UIColor=#colorLiteral(red: 0.9972997308, green: 0.9770990014, blue: 0.9307858348, alpha: 1)
    let darkeryellow:UIColor=#colorLiteral(red: 0.9914044738, green: 0.9538459182, blue: 0.8533558249, alpha: 1)
    static func dateFormatted(input:Double,withFormat format : String) -> String{
        let date = Date(timeIntervalSince1970: input)
        let dateFormatter = DateFormatter()
       // dateFormatter.timeZone = TimeZone(abbreviation: "CST") //Set timezone that you want
      //  dateFormatter.locale = NSLocale.init(localeIdentifier: "CN") as Locale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    static func heightForString(string:String)->CGFloat{
        let frame = NSString(string: string).boundingRect(
            with: CGSize(width: screenWidth-16, height: .infinity),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: [.font : UIFont.systemFont(ofSize: 18)],
            context: nil)
        return frame.size.height
    }
    
    static func saveImage(imageName: String, image: UIImage) {
     guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.pngData() else { return }
    

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }

    }


    static func loadImageFromDiskWith(fileName: String) -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }
    
    static func getTag(subject:String)->([String],String){
        var subjectNoTag = subject
        let regexp = "\\[([^]]+)\\]"
        var results:[String]=[]
        var range = subject.range(of:regexp, options: .regularExpression)
        while(range != nil){
            
            var result = subjectNoTag[range!]
            result.removeFirst()
            result.removeLast()
            results.append(String(result))
            subjectNoTag.removeSubrange(range!)
            range = subjectNoTag.range(of:regexp, options: .regularExpression)
        }
        if subjectNoTag.first == " "{
            subjectNoTag.removeFirst()
        }
        return (results,subjectNoTag)
    }
    
    static func getImgLink(content:String)->String?{
        let regexp = "\\[img\\](.*?)\\[\\/img\\]"
        if let range = content.range(of:regexp, options: .regularExpression) {
            let result = content[range]
            let begin = result.index(result.startIndex, offsetBy: 5)
            let end = result.index(result.endIndex, offsetBy: -6)
            let newResult = result[begin..<end]
            
            return String(newResult)
        }
        return nil
    }
    
    static func getQuoteRange(content:String)->[NSRange]{
       // let regexp = "\\[quote\\]([^]]+)\\[\\quote\\]"
        var result:[NSRange]=[]
        let regex = try! NSRegularExpression(pattern: #"\[quote\]([\s\S]*?)\[\/quote\]"#, options: [])

       // let input = "I'm looking for @{1 | Tom Lofe} and @{2 | Cristal Dawn}"
        let range = NSRange(location: 0, length: content.count)

        for match in regex.matches(in: content, options: [], range: range) {
            result.append(match.range)
        }
        return result
    }
    
    static func getImgRange(content:String)->[NSRange]{
       // let regexp = "\\[quote\\]([^]]+)\\[\\quote\\]"
        var result:[NSRange]=[]
        let regex = try! NSRegularExpression(pattern: #"\[img\]([\s\S]*?)\[\/img\]"#, options: [])

       // let input = "I'm looking for @{1 | Tom Lofe} and @{2 | Cristal Dawn}"
        let range = NSRange(location: 0, length: content.count)

        for match in regex.matches(in: content, options: [], range: range) {
            result.append(match.range)
        }
        return result
    }
    
    static func resizeImg(sourceImage:UIImage,i_width:CGFloat)->UIImage{
        let oldWidth = sourceImage.size.width
        let scaleFactor = i_width / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        sourceImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
            
    static func fontColorRange(content:NSMutableAttributedString){
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        let cgBlack = CGColor(colorSpace: sRGB, components: [0, 0, 0, 1])!
        let black = UIColor(cgColor: cgBlack)
        var label = UIColor.black
        if #available(iOS 13.0, *) {
             label = UIColor.label
        } else {
             label = UIColor.black
        }
        let blackAttributes = [NSAttributedString.Key.foregroundColor: label]
        let redAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]

        content.enumerateAttributes(in: NSRange(0..<content.length)) { (attributes, range, stop) in
            for (_, textColor) in attributes {
                if  (textColor as? UIColor) == black {
                    content.addAttributes(blackAttributes , range: range)
                }
                if  (textColor as? UIColor) == UIColor.red {
                    content.addAttributes(redAttributes , range: range)
                }
            }
        }
    }
    
    static func fontSize(content:String)->String{
        var s = content
        let font_size = fontsize
        let reg = try! NSRegularExpression(pattern: "\\[size=(\\d+)%\\]([\\s\\S]*?)\\[\\/size\\]", options: [])
        let matches = reg.matches(in: s, options: [], range: NSRange(location: 0, length: s.utf16.count))
        let rev = matches.reversed() // work backwards for replacement
        for match in rev {
            let r = match.range
            let size = s[Range(match.range(at:1), in:s)!]
            let text = s[Range(match.range(at:2), in:s)!]
            let prefix = "<font size=\""
            let num = String(Double(size)! * font_size/100.0/3.2)
            //print(num)
            let rest = "\">" + text + "</font>"
            s = s.replacingCharacters(in: Range(r, in:s)!, with: prefix + num + rest)
        }
        return s
    }
}

extension NSAttributedString {
    func attributedStringWithResizedImages() -> NSAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let attachement = value as? NSTextAttachment {
                let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)!
              let screenSize: CGRect = UIScreen.main.bounds
               if image.size.width > screenSize.width {
                   let newImage = image.resizeImage(scale: (screenSize.width-16)/image.size.width)
                   let newAttribut = NSTextAttachment()
                   newAttribut.image = newImage
                text.addAttribute(NSAttributedString.Key.attachment, value: newAttribut, range: range)
               }
            }
        })
        return text
    }
}

extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        let rect = CGRect(origin: CGPoint.zero, size: newSize)

        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIColor {
    func isEqualWithConversion(_ color: UIColor) -> Bool {
        guard let space = self.cgColor.colorSpace
            else { return false }
        guard let converted = color.cgColor.converted(to: space, intent: .absoluteColorimetric, options: nil)
            else { return false }
        return self.cgColor == converted
    }
}


@IBDesignable
class PaddedLabel: UILabel {

    @IBInspectable var inset:CGSize = CGSize(width: 0, height: 0)

    var padding: UIEdgeInsets {
        var hasText:Bool = false
        if let t = self.text?.count, t > 0 {
            hasText = true
        }
        else if let t = attributedText?.length, t > 0 {
            hasText = true
        }

        return hasText ? UIEdgeInsets(top: inset.height, left: inset.width, bottom: inset.height, right: inset.width) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let p = padding
        let width = superContentSize.width + p.left + p.right
        let heigth = superContentSize.height + p.top + p.bottom
        return CGSize(width: width, height: heigth)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let p = padding
        let width = superSizeThatFits.width + p.left + p.right
        let heigth = superSizeThatFits.height + p.top + p.bottom
        return CGSize(width: width, height: heigth)
    }
}

import XLActionController


open class ActionStyleCell: ActionCell {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    func initialize() {
        backgroundColor = .systemBackground
        actionImageView?.clipsToBounds = true
        actionImageView?.layer.cornerRadius = 5.0
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        selectedBackgroundView = backgroundView
    }
}

open class TwitterActionControllerHeader: UICollectionReusableView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .systemBackground
        return bottomLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["label": label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["label": label]))
        addSubview(bottomLine)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(1)]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["line": bottomLine]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["line": bottomLine]))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public struct ActionData {
    
    public fileprivate(set) var title: String?
    public fileprivate(set) var subtitle: String?
    public fileprivate(set) var image: UIImage?
    
    public init(title: String) {
        self.title = title
    }
    
    public init(title: String, subtitle: String) {
        self.init(title: title)
        self.subtitle = subtitle
    }
    
    public init(title: String, subtitle: String, image: UIImage) {
        self.init(title: title, subtitle: subtitle)
        self.image = image
    }
    
    public init(title: String, image: UIImage) {
        self.init(title: title)
        self.image = image
    }
}

open class SortActionController: ActionController<ActionStyleCell, ActionData, TwitterActionControllerHeader, String, UICollectionReusableView, Void> {

    static let bottomPadding: CGFloat = 20.0

    lazy var hideBottomSpaceView: UIView = {
        let width = collectionView.bounds.width - safeAreaInsets.left - safeAreaInsets.right
        let height = contentHeight + SortActionController.bottomPadding + safeAreaInsets.bottom
        let hideBottomSpaceView = UIView(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        hideBottomSpaceView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        hideBottomSpaceView.backgroundColor = .systemBackground
        return hideBottomSpaceView
    }()

    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        settings.animation.scale = nil
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.6
        settings.behavior.hideNavigationBarOnShow = false
        cellSpec = CellSpec.nibFile(nibName: "ActionStyleCell", bundle: Bundle(for: ActionStyleCell.self), height: { _ in 56 })
        headerSpec = .cellClass(height: { _ -> CGFloat in return 45 })

        onConfigureHeader = { header, title in
            header.label.text = title
        }
        onConfigureCellForAction = { [weak self] cell, action, indexPath in
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            cell.separatorView?.isHidden = indexPath.item == (self?.collectionView.numberOfItems(inSection: indexPath.section))! - 1
            cell.alpha = action.enabled ? 1.0 : 0.5
        }
    }
  
    required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.clipsToBounds = false
        collectionView.addSubview(hideBottomSpaceView)
        collectionView.sendSubviewToBack(hideBottomSpaceView)

    }
    

    @available(iOS 11, *)
    override open func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        hideBottomSpaceView.frame.size.height = contentHeight + SortActionController.bottomPadding + safeAreaInsets.bottom
        hideBottomSpaceView.frame.size.width = collectionView.bounds.width - safeAreaInsets.left - safeAreaInsets.right
    }

    override open func dismissView(_ presentedView: UIView, presentingView: UIView, animationDuration: Double, completion: ((_ completed: Bool) -> Void)?) {
        onWillDismissView()
        let animationSettings = settings.animation.dismiss
        let upTime = 0.1
        UIView.animate(withDuration: upTime, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.collectionView.frame.origin.y -= 10
        }, completion: { [weak self] (completed) -> Void in
            UIView.animate(withDuration: animationDuration - upTime,
                delay: 0,
                usingSpringWithDamping: animationSettings.damping,
                initialSpringVelocity: animationSettings.springVelocity,
                options: UIView.AnimationOptions.curveEaseIn,
                animations: { [weak self] in
                    presentingView.transform = CGAffineTransform.identity
                    self?.performCustomDismissingAnimation(presentedView, presentingView: presentingView)
                },
                completion: { [weak self] finished in
                    self?.onDidDismissView()
                    completion?(finished)
                })
        })
    }
}


