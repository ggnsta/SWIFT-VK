//
//  ViewController.swift
//  SWIFT-VK
//
//  Created by hs on 05.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit
import VK_ios_sdk

class ViewController: UIViewController, VKSdkDelegate, VKSdkUIDelegate {

    
    let vk_app_id="6750726"// уникальный айди приложение
    let permissions = ["friends", "messages", "wall","music"]// список прав
  
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("vkSdkShouldPresent")
        present(controller!, animated: false, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("vkSdkNeedCaptchaEnter")
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print("vkSdkAccessAuthorizationFinished")
        print(result.token)
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sdkInstance = VKSdk.initialize(withAppId: vk_app_id)
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
     
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        VKSdk.wakeUpSession( permissions , complete: { (state, error) -> Void in
            if (state == VKAuthorizationState.authorized) {
                self.goToNextController()
            } else if ((error) != nil) {
                print("ERROR: \(error as! String)")
            } else {
                VKSdk.authorize(self.permissions, with: .disableSafariController)
            }
        })
    }
    @IBAction func Logout(_ sender: UIButton) {
        VKSdk.forceLogout()
    }
    private func goToNextController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TabViewController")
        self.present(controller, animated: true, completion: nil)
    }

   
    
}

