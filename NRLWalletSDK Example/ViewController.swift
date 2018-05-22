//
//  ViewController.swift
//  NRLWalletSDK Example
//
//  Created by David Bala on 5/3/18.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import UIKit
import NRLWalletSDK

//data extension to convert binary data to hex string
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Generate mnemonic and seed
        do {
            let mnemonic = try NRLMnemonic.generateMnemonic(strength: .normal, language: .english)
            print("mnemonic = \(mnemonic.joined(separator: " "))")

            let seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: "Test")
            print("\nseed = \(seed.hexEncodedString())")
            
            // Ethereum : 60
            let etherWallet = NRLWallet(seed: seed, network: .main(.ethereum))
            etherWallet.generateExternalKeyPair(at: 0)
            
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
