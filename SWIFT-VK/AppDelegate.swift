//
//  AppDelegate.swift
//  SWIFT-VK
//
//  Created by hs on 05.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit
import VK_ios_sdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let loginControler = ViewController()
        loginControler.view.backgroundColor = .white
        if let window = self.window{
            window.rootViewController = loginControler
            window.makeKeyAndVisible()
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        VKSdk.processOpen(url, fromApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?)
        return true
    }

}

