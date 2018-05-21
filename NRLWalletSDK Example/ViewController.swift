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
            let mnemonic = try NRLMnemonic.generateMnemonic(strength: .hight, language: .english)
            print("mnemonic = \(mnemonic.joined(separator: " "))")

            let seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: "Test")
            print("\nseed = \(seed.toHexString())")
            
            // Ethereum : 60
            let etherWallet = NRLWallet(seed: seed, network: .main(.ethereum))
            etherWallet.generateExternalKeyPair(at: 2)
            
            var privateKey = etherWallet.getWIF()
            var publicKey = etherWallet.getPublicKey()
            var address = etherWallet.getAddress()

            print("\nEthereum private key = \(privateKey)")
            print("Ethereum public key = \(publicKey)")
            print("Ethereum address = \(address)")
            
            // NEO : 888
            let neoWallet = NRLWallet(seed: seed, network: .main(.neo))
            neoWallet.generateExternalKeyPair(at: 2)
            
            privateKey = neoWallet.getWIF()
            publicKey = neoWallet.getPublicKey()
            address = neoWallet.getAddress()
            
            print("\nNeo private key = \(privateKey)")
            print("Neo public key = \(publicKey)")
            print("Neo address = \(address)")
            
            
        } catch {
            print(error)
        }
    }
}
