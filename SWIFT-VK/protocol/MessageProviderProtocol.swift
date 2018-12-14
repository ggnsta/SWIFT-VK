//
//  MessageProviderProtocol.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation

protocol MessagesProviderProtocol {
    func get(messagesListWith treatmentMessages: @escaping ([Message]) -> Void)
    func delete(chatBy id: NSNumber)
   func get(longPollServerWith callBack: @escaping () -> Void)
    func registration(longPollWith callBack: @escaping () -> Void)
}
