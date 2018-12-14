//
//  MessagesListTableViewCell.swift
//  SWIFT-VK
//
//  Created by hs on 13.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit

class MessagesListTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var countUnreadMessages: UILabel!
    @IBOutlet weak var bubbleLastMessage: UIView!
    private let colorBackground = UIColor(red:0.88, green:0.95, blue:0.98, alpha:1.0)
    
    public func setAvatar(image: UIImage) {
        avatar?.image = image
        avatar?.layer.masksToBounds = false
        avatar?.layer.cornerRadius = avatar.layer.frame.height / 2
        avatar?.clipsToBounds = true
    }
    
    public func set(name: String) {
        self.name?.text = name
    }
    
    public func set(textLastMessage text: String, isRead: Bool) {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributedString.set(color: UIColor(red:0.13, green:0.51, blue:1.00, alpha:1.0), forText: "You:")
        lastMessage.attributedText = attributedString
        bubbleLastMessage.layer.cornerRadius = bubbleLastMessage.layer.frame.height / 2
        isRead ? (bubbleLastMessage.backgroundColor = nil) : (bubbleLastMessage.backgroundColor = colorBackground)
    }
    
    public func set(date: NSNumber) {
        let date = Date(timeIntervalSince1970: date as! Double)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM"
        let strDate = dateFormatter.string(from: date)
        self.date?.text = strDate
    }
    
    public func set(countUnreadMessages count: NSNumber) {
        if count != 0 {
            countUnreadMessages.isHidden = false
            countUnreadMessages.clipsToBounds = true
            countUnreadMessages.text = count.stringValue
            countUnreadMessages.layer.cornerRadius = countUnreadMessages.layer.frame.height / 2
            self.backgroundColor = colorBackground
        } else {
            countUnreadMessages.isHidden = true
            self.backgroundColor = nil
        }
    }
}

extension NSMutableAttributedString {
    func set(color: UIColor, forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}
