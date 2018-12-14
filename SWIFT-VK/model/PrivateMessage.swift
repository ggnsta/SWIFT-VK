//
//  PrivateMessage.swift
//  SWIFT-VK
//
//  Created by hs on 13.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//
import Foundation

struct PrivateMessage {
    var message: String
    var date: NSNumber
    var isMine: Bool
    var isRead: Bool
    var id: NSNumber
    var attachments: [AttachmentMessage]?
}
