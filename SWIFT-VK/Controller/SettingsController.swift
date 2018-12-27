//
//  SettingsController.swift
//  SWIFT-VK
//
//  Created by hs on 27.12.2018.
//
//  Copyright © 2018 hs. All rights reserved.

import UIKit
import VK_ios_sdk

class SettingsController: UIViewController{
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
   
    @IBAction func TouchLockbUTTON(_ sender: UIButton) {
    }
    
    @IBAction func ForcelogoutButton(_ sender: UIButton) {
        VKSdk.forceLogout();
        goToLoginController();
    }
    
    private func goToLoginController() {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginVievController")
        self.present(controller, animated: true, completion: nil)
    }
}

