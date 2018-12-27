//
//  CacheImages.swift
//  SWIFT-VK
//
//   Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit

class CacheImages: CacheProtocol {
    var dictionaryCache = [NSString: UIImage]()
    
    func add(imageToCacheBy key: NSString, and object: UIImage) {
        dictionaryCache[key] = object
    }
    
    func check(imageInCacheBy key: NSString) -> UIImage? {
        return dictionaryCache[key]
    }
}
