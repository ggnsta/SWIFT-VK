//
//  VKProvider.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation
import VK_ios_sdk
class VKProvider: FriendsListProviderProtocol, MessagesProviderProtocol{

    
    private var ts: NSNumber?
    private var server: String?
    private var key: String?
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
 
    init() {
        serialQueue = DispatchQueue(label: "queue")
    }
    
    
    public func get(friendsListWith treatmentFriends: @escaping ([Person]) -> Void) {
        serialQueue.async {
            var bioFriends = [Person]()
            VKRequest(method: "friends.get", parameters: ["fields":"photo_50", "order":"hints"]).execute(resultBlock: { (response) in
                let json = response?.json as! Dictionary<String, Any>
                let items = json["items"] as! Array<Dictionary<String, Any>>
                items.forEach {
                    bioFriends.append(Person(id: $0["id"] as? NSNumber,
                                             name: $0["first_name"] as? String,
                                             surname: $0["last_name"] as? String,
                                             avaImgUrl: $0["photo_50"] as? String,
                                             isOnline: $0["online"] as? Bool))
                }
                DispatchQueue.main.async {
                    treatmentFriends(bioFriends)
                }
            }, errorBlock: { (error) in
                print("ERROR: \(String(describing: error))")
            })
        }
    }
}
