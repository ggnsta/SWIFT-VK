//
//  CacheImages.swift
//  Messenger
//
//  Created by Dmitry Vorozhbicky on 31.07.2018.
//  Copyright © 2018 Dmitry Vorozhbicky. All rights reserved.
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
