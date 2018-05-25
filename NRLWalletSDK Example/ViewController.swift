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
    
    // Convert 0 ... 9, a ... f, A ...F to their decimal value,
    // return nil for all other input characters
    fileprivate func decodeNibble(_ u: UInt16) -> UInt8? {
        switch(u) {
        case 0x30 ... 0x39:
            return UInt8(u - 0x30)
        case 0x41 ... 0x46:
            return UInt8(u - 0x41 + 10)
        case 0x61 ... 0x66:
            return UInt8(u - 0x61 + 10)
        default:
            return nil
        }
    }
    
    init?(fromHexEncodedString: String) {
        var str = fromHexEncodedString
        if str.count%2 != 0 {
            // insert 0 to get even number of chars
            str.insert("0", at: str.startIndex)
        }
        
        let utf16 = str.utf16
        self.init(capacity: utf16.count/2)
        
        var i = utf16.startIndex
        while i != str.utf16.endIndex {
            guard let hi = decodeNibble(utf16[i]),
                let lo = decodeNibble(utf16[utf16.index(i, offsetBy: 1, limitedBy: utf16.endIndex)!]) else {
                    return nil
            }
            var value = hi << 4 + lo
            self.append(&value, count: 1)
            i = utf16.index(i, offsetBy: 2, limitedBy: utf16.endIndex)!
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Generate mnemonic and seed
        do {
            let mnemonic = try NRLMnemonic.generateMnemonic(strength: .hight, language: .english)
            print("mnemonic = \(mnemonic.joined(separator: " "))")

            let seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: "Test")
            print("\nseed = \(String(describing: seed.hexEncodedString()))")
            
            print("\n------------------------- Ethereum ----------------------------\n")
            // Ethereum : 60ß
            let etherWallet = NRLWallet(seed: seed, network: .main(.ethereum))
            etherWallet.generateExternalKeyPair(at: 0)
            
            var privateKey = etherWallet.getWIF()
            var publicKey = etherWallet.getPublicKey()
            var address = etherWallet.getAddress()

            print("\nEthereum private key = \(privateKey)")
            print("Ethereum public key = \(publicKey)")
            print("Ethereum address = \(address)")
            
            print("\n------------------------- NEO ----------------------------\n")
            // NEO : 888
            let neoWallet = NRLWallet(seed: seed!, network: .main(.neo))
            neoWallet.generateExternalKeyPair(at: 2)
            
            privateKey = neoWallet.getWIF()
            publicKey = neoWallet.getPublicKey()
            address = neoWallet.getAddress()
            
            print("\nNeo private key = \(privateKey)")
            print("Neo public key = \(publicKey)")
            print("Neo address = \(address)")
            
            
            print("\n------------------------- Bitcoin ----------------------------\n")
            // Bitcoin : 0
            let bitcoinWallet = NRLWallet(seed: seed!, network: .main(.bitcoin))
            bitcoinWallet.generateExternalKeyPair(at: 0)
            
            privateKey = bitcoinWallet.getWIF()
            publicKey = bitcoinWallet.getPublicKey()
            address = bitcoinWallet.getAddress()
            
            print("\nBitcoinWallet private key = \(privateKey)")
            print("BitcoinWallet public key = \(publicKey)")
            print("BitcoinWallet address = \(address)")
            
            
            print("\n------------------------- Litecoin ----------------------------\n")
            // Litecoin : 2
            let litecoinWallet = NRLWallet(seed: seed!, network: .main(.litecoin))
            litecoinWallet.generateExternalKeyPair(at: 0)
            
            privateKey = litecoinWallet.getWIF()
            publicKey = litecoinWallet.getPublicKey()
            address = litecoinWallet.getAddress()
            
            print("\nLitecoinWallet private key = \(privateKey)")
            print("LitecoinWallet public key = \(publicKey)")
            print("LitecoinWallet address = \(address)")
            
            print("\n------------------------- Stellar ----------------------------\n")
            // Stellar : 148
            let stellarWallet = NRLWallet(seed: seed!, network: .main(.stellar))
            stellarWallet.generateExternalKeyPair(at: 0)
            
            privateKey = stellarWallet.getWIF()
            publicKey = stellarWallet.getPublicKey()
            address = stellarWallet.getAddress()
            
            print("\n stellarWallet private key = \(privateKey)")
             print("stellarWallet public key = \(publicKey)")
            print("stellarWallet address = \(address)")
            
            print("\n-----------------------------------------------------\n")

        } catch {
            print(error)
        }
    }
}
