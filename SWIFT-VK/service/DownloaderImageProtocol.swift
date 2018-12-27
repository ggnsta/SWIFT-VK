//
//  SessionProtocol.swift
//  SWIFT-VK
//
//   Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit
typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())

protocol DownloaderImageProtocol {
    func download(imageWithImagePath imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler)
}
