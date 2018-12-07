//
//  MessageInfo.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation

struct ResponseMessages: Codable {
    var response: Something?
}

struct Something: Codable {
    var count: Int?
    var items: [Items?]
}

struct Items: Codable {
    var message: Message?
    var in_read: Int?
    var out_read: Int?
}

struct Message: Codable {
    var id: Int?
    var date: Int?
    var out: Int?
    var user_id: Int?
    var read_state: Int?
    var title: String?
    var body: String?
    var random_id: Int?
}
