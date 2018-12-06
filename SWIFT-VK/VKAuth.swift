//
//  VKAuth.swift
//  SWIFT-VK
//
//  Created by hs on 04.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit
import VK_ios_sdk

class VKAuth: NSObject {
    
    static let shared = VKAuth()
    static let vk_app_id="6750726"// уникальный айди приложение
    let sdkInstance=VKSdk.initialize(withAppId: "6750726")//инициализируем сдк
    let permissions = ["friends", "messages", "wall","music"]// список прав
    var token: VKAccessToken?
    
    //////////////
    func login()
    {
        VKSdk.wakeUpSession(self.permissions, complete: {(state, error) -> Void in
            switch (state){
            case VKAuthorizationState.authorized:
                print("1")
            case VKAuthorizationState.initialized:
                
                VKSdk.authorize(self.permissions)
            default:
                print("network error")
                break
            }
        })
    }
    
    
    
    func logout(){
        VKSdk.forceLogout()
    }
}

extension  VKAuth: VKSdkDelegate{
    
    func vkSdkUserAuthorizationFailed() {
        print(" vkSdkUserAuthorizationFailed")
        
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        guard let result = result, let token = result.token else {return}
        self.token = token
        print("token est")
        
    }
    
    func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
        self.token = nil
        VKSdk.authorize(self.permissions)
    }
}

extension VKAuth: VKSdkUIDelegate
{
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("vksdkshouldpresent")
        
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("vkSdkNeedCaptchaEnter")
    }
}
