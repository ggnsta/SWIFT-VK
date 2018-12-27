//
//  DownloadSession.swift
//  SWIFT-VK
//
//   Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//
//  Сеансы:
//  Сеансы по умолчанию - хранят кэш и данные на диске
//  Эфемерные - не хранят в RAM, чистятся когда завершается сеанс.
//  Фоновые - отдельный процесс обрабатывает всю передачу данных.

//  Задачи:
//  Задачи данных отправляют и получают использование данных NSData объекты. Задачи данных могут возвратить данные Вашему приложению одна часть за один раз после того, как каждая часть данных будет получена, или одновременно через обработчик завершения. Поскольку задачи данных не хранят данные к файлу, они не поддерживаются в фоновых сеансах.
//  В то время как приложение не работает, задачи загрузки получают данные в форме файла и поддерживают фоновые загрузки.
//  В то время как приложение не работает, задачи загрузки отправляют данные (обычно в форме файла) и поддерживают фоновые загрузки.
//  URLSessionTask-Задача, как и загрузка определенного ресурса, выполняется в сеансе URL.
//  URLSessionDataTask-Задача сеанса URL, которая возвращает загруженные данные непосредственно в память.
//  URLSessionUploadTask-Задача сеанса URL, которая загружает данные в сеть в тело запроса.
//  URLSessionDownloadTask- сеанса URL, которая хранит загруженные данные в файле.
//  cache -> массив объектов, но будет проблема с многопоточностью тк я к массиву обращаюсь с разных потоков/ Определить протокол и кэш сделать отдельным классом

import UIKit

public class DownloaderImage: DownloaderImageProtocol {
    //  NSCache-временное хранение переходных пар ключ-значение(временное хранение объектов с временными данными)
//    var cache: NSCache<NSString, UIImage>!
    private var cache: CacheProtocol
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    init() {
//        self.cache = NSCache()
        cache = CacheImages()
//        cache = FileSystemImagesCache()
        serialQueue = DispatchQueue(label: "queue")
    }
    
    func download(imageWithImagePath imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        //достал из кэша по ключу объект image что бы избежать повторного скачивание
        serialQueue.async {
            if let image = self.cache.check(imageInCacheBy: imagePath as NSString) {
                DispatchQueue.main.async {
                    completionHandler(image)
                }
            } else {
                let url: URL! = URL(string: imagePath)
                self.session.dataTask(with: url, completionHandler: { [weak self] (data, _, error) -> Void in
                    guard let data = data , error == nil, let img = UIImage(data: data) else { return }
                    //убираю объект image в кэш с ключом
                    self?.serialQueue.async {
                        self?.cache.add(imageToCacheBy: imagePath as NSString, and: img)
                        DispatchQueue.main.async {
                            completionHandler(img)
                        }
                    }
                }).resume()
            }
        }
    }
}

//            создает буфер данных по юрл-у (т/е/ берет данные по юрл и пишет их в экземпляр) синхронно
//            if let data = try? Data(contentsOf: url) {
//                let img: UIImage! = UIImage(data: data)
//                self.cache.setObject(img, forKey: imagePath as NSString)
//                DispatchQueue.main.async {
//                    completionHandler(img)
//                }
//            }
