//
//  FileSystemImagesCache.swift
//  SWIFT-VK
//
//   Created by hs on 06.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//
//  sandbox:
//  documents - пользовательские данные, копируется в iT
//  Documents/Inbox - открыт для внешних объектов, можно удалить и читать, но не создать или изменять файлы
//  Library/ - для не пользовательских данных, содержит:
//      - Application Support - хранение всех файлов данных приложения кроме связанных с документами пользователя
//      - Caches - любые файлы легко воссоздаваемые, не копируется в iT
//  tmp/ - временные файлы, не сохраняются между запусками приложения


import UIKit

class FileSystemImagesCache: CacheProtocol {
    
    func add(imageToCacheBy key: NSString, and object: UIImage) {
        //внесение изменений в файловую систему, возвращение общего объекта ФМ, urls-возвращает массив адресов для общего каталога
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        //добавление к строке адреса к каталогу название файла
        let fileURL = documentsDirectory.appendingPathComponent("\(key).jpg")
        //перевод в формат JPEG и проверка на существование файла по указанному адресу
        if let data = object.jpegData(compressionQuality: 1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                //записывает данные по адресу
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }
    
    func check(imageInCacheBy key: NSString) -> UIImage? {
        //создаем новую строку с адресом добавляя в нее название файла
        let path = self.getDirectoryPath().appendingPathComponent("\(key).jpg")
        //возвращаем файл лежащий по адресу
        return UIImage(contentsOfFile: path)
    }
    
    func getDirectoryPath() -> NSString {
        //Создает список путей для указанных каталогов в указанных доменах и берет адрес первого элемента
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return paths as NSString
    }
}
