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

        // Generate mnemonic and seed
        do {
            let mnemonic = try NRLMnemonic.generateMnemonic(strength: .normal, language: .english)
            print("mnemonic = \(mnemonic.joined(separator: " "))")

            let seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: "Test")
            print("seed = \(seed.toHexString())")
            
            let wallet = NRLWallet(seed: seed, network: .main(.ethereum))
            let privateKey = try wallet.generateExternalPrivateKey(at: 60)
            let publicKey = privateKey.nrlPublicKey()
            
            print("private key = \(privateKey.raw.toHexString())")
            print("public key = \(publicKey.raw.toHexString())")
        } catch {
            print(error)
        }
    }
}
