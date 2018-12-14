//
//  PrivateChatProviderProtocol.swift
//  SWIFT-VK
//
//  Created by hs on 13.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation

protocol PrivateChatProviderProtocol {
    func get(chatMessagesListBy id: String, lastMessageId: String, count: String, with treatmentMessages: @escaping ([PrivateMessage]) -> Void)
    func send(message: String, byUserId id: String)
    func get(longPollServerWith callBack: @escaping () -> Void)
    func registration(longPollWith callBack: @escaping () -> Void)
    func markAsRead(messagesBy id: String)
    func delete(messageBy id: NSNumber)
}
