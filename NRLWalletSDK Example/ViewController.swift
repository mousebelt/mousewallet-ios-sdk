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
            
            // Ethereum : 60
            let etherWallet = NRLWallet(seed: seed, network: .main(.ethereum))
            let privateKey = try etherWallet.generateExternalPrivateKey(at: 60)
            let publicKey = privateKey.nrlPublicKey()
            
            print("eth private key = \(privateKey.raw.toHexString())")
            print("eth public key = \(publicKey.raw.toHexString())")
            
            let address = NRLEthereum.Utils.publicToAddressStr(publicKey.raw);
            print("eth address = \(address)")
            
            // NEO : 888
            let neoWallet = NRLWallet(seed: seed, network: .main(.neo))
            let neoPrivateKey = try neoWallet.generateExternalPrivateKey(at: 60)
            let neoPublicKey = neoPrivateKey.nrlPublicKey()
            
            print("neo private key = \(neoPrivateKey.raw.toHexString())")
            print("neo public key = \(neoPublicKey.raw.toHexString())")
        } catch {
            print(error)
        }
    }
}
