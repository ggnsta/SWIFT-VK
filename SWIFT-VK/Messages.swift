//
//  Messages.swift
//  SWIFT-VK
//
//  Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import Foundation
import VK_ios_sdk

class Messages{
    var requestMessages = VKRequest.init(method: "messages.getDialogs", parameters: [VK_API_COUNT : 50])
    func requestMessages(completion: @escaping (ResponseMessages?) -> Void) {
        requestMessages?.execute(resultBlock: { (response) in
            
            let stringJson = response?.responseString.data(using: .utf8)
            
            let decoder = JSONDecoder()
            
            do {
                let product = try decoder.decode(ResponseMessages.self, from: stringJson!)
                completion(product)
                print(product)
            }
            catch {
                print("error: \(error)")
            }
            
        }, errorBlock: { (Error) in
            print(Error.debugDescription)
        })
    }
    
}
