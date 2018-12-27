//
//  CacheProtocol.swift
//  SWIFT-VK
//
//   Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit

protocol CacheProtocol {
    func add(imageToCacheBy key: NSString, and object: UIImage)
    func check(imageInCacheBy key: NSString) -> UIImage?
}
