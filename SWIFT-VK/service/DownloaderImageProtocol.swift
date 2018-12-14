//
//  SessionProtocol.swift
//  Messenger
//
//  Created by Dmitry Vorozhbicky on 26.07.2018.
//  Copyright © 2018 Dmitry Vorozhbicky. All rights reserved.
//

import UIKit
typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())

protocol DownloaderImageProtocol {
    func download(imageWithImagePath imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler)
}
