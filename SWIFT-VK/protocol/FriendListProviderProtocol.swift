//
//  FriendListProviderProtocol.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation
protocol FriendsListProviderProtocol {
    //замыкание было передано в функцию в качестве аргумента и вызывается уже после того, как функция вернулась
    func get(friendsListWith treatmentFriends: @escaping ([Person]) -> Void)
    func delete(friendBy id: NSNumber)
}
