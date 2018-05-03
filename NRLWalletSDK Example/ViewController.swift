//
//  ViewController.swift
//  NRLWalletSDK Example
//
//  Created by David Bala on 5/3/18.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import UIKit
import NRLWalletSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let mnemonic = try NRLMnemonic.generateMnemonic(strength: 128, language: .english)
            print("mnemonic = \(mnemonic)")
            let seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, passphrase: "Test", language: .english)
            print("seed = \(seed)")
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

