//
//  ViewController.swift
//  SWIFT-VK
//
//  Created by hs on 05.12.2018.
//  Copyright © 2018 hs. All rights reserved.
//

import UIKit
import VK_ios_sdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBOutlet weak var la: UILabel!
    @IBAction func but(_ sender: UIButton) {
    
        VKAuth.shared.login()
        self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
}

