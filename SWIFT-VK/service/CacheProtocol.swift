//
//  CacheProtocol.swift
//  Messenger
//
//  Created by Dmitry Vorozhbicky on 31.07.2018.
//  Copyright © 2018 Dmitry Vorozhbicky. All rights reserved.
//

import UIKit

protocol CacheProtocol {
    func add(imageToCacheBy key: NSString, and object: UIImage)
    func check(imageInCacheBy key: NSString) -> UIImage?
}
