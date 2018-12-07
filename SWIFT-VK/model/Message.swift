//
//  Message.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation
struct Message {
    var person: Person
    var lastMessage: String
    var lastDateMessage: NSNumber
    var id: NSNumber?
    var unreadCount: NSNumber?
    var isSentRead: Bool?
}
