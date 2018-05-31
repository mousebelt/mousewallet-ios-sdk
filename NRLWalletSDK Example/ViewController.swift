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
        DDLog.add(DDTTYLogger.sharedInstance())

        // Generate mnemonic and seed
        do {
            let mnemonic = try NRLMnemonic.generateMnemonic(strength: .hight, language: .english)
            let bindedString = mnemonic.joined(separator: " ")
            print("mnemonic = \(bindedString)")

            var seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: "Test")
            print("\nseed = \(String(describing: seed.hexEncodedString()))")
            
            var privateKey: String
            var publicKey: String
            var address: String
            
//            print("\n------------------------- Ethereum ----------------------------\n")
//            // Ethereum : 60ß
//            let etherWallet = NRLWallet(seed: seed, network: .main(.ethereum))
//            etherWallet.generateExternalKeyPair(at: 0)
//
//            var privateKey = etherWallet.getWIF()
//            var publicKey = etherWallet.getPublicKey()
//            var address = etherWallet.getAddress()
//
//            print("\nEthereum private key = \(privateKey)")
//            print("Ethereum public key = \(publicKey)")
//            print("Ethereum address = \(address)")
//
//            print("\n------------------------- NEO ----------------------------\n")
//            // NEO : 888
//            let neoWallet = NRLWallet(seed: seed, network: .main(.neo))
//            neoWallet.generateExternalKeyPair(at: 2)
//
//            privateKey = neoWallet.getWIF()
//            publicKey = neoWallet.getPublicKey()
//            address = neoWallet.getAddress()
//
//            print("\nNeo private key = \(privateKey)")
//            print("Neo public key = \(publicKey)")
//            print("Neo address = \(address)")
            
            
            print("\n------------------------- Bitcoin ----------------------------\n")
            // Bitcoin : 0
            /* menmonic= "click offer off current alien soon foster wide senior student mystery agree target grace whale puppy slim join wet plug love trophy federal destroy"
             
             address:
                 myqAKSukSdtUH4YUregNvfjEWJMk3jTEUj,
                 mjnt7mvGW3mZNd6Ao1SamDDezcWrpT8n8r,
                 mvb4PXxf77LvtF9ooy1N77tzZSD5bqfFWT,
                 n42oeaDttQTJXxVo6wcHFr8AXNe4kifEAm,
                 mo89Y9csq3Yy96Vkp8XoZqnKUSFKjedhB7,
                 mpaQosi6hUaSPyv4Q5TmHm1BpAQJMWo8Nn,
                 mn1qQyyUMAQTK4Qjebof7gSXks7pUFDibq,
             privkeys:
                 cS2zeeAtj51W3Pre6bSa8pjcr4nDmFSWQa8ynGzDEbt9xu7w3kBd,
                 cPwaYXfxwP7UpEMAczgcub6V5ugK3EVspzmFKuUrQAnqbRD8hzND,
                 cUFKu2NJnQxAGEbZwJjsHSzuN1ei2KM4EywtNNg86V9JUVRPfRLq,
                 cPTzK5xGh2b6WmbsC2RV4V4G7sGWNtfewv2JcDofysauQrnPMsUK,
                 cQErDBqZqbiXqoiTRVHJTkgbX42qqFJmSpoByLLbCRy6xeaFmKEt,
                 cRw3wwp8sJiiDbvSbSYKYZ7Zzz7mG5ZayC5aF2oCPTTZCw99KFtU,
                 cQHC62RtXrnidk55i19rpWBJGKMXHVG3wWnahxoPMRzVcFtN5aRb,
            */
            seed = Data(fromHexEncodedString: "47d8d8898556e5c4fcf042b249ef92160e667046d7ff487392a9e6ca9e1d912b11a7b134baf7a8893c92d1a40731b08d1ef24789128d07101df740ad1ba4a12c")!

            let bitcoinWallet = NRLWallet(seed: seed, network: .test(.bitcoin))
            bitcoinWallet.generateExternalKeyPair(at: 0)
            
            privateKey = bitcoinWallet.getWIF()
            publicKey = bitcoinWallet.getPublicKey()
            address = bitcoinWallet.getAddress()
            
            print("\nBitcoinWallet private key = \(privateKey)")
            print("BitcoinWallet public key = \(publicKey)")
            print("BitcoinWallet address = \(address)")
            
            print("\nCreate Own Wallet")
            bitcoinWallet.createOwnWallet()
            print("\nCreate Peer Group")
            bitcoinWallet.createPeerGroup()
            print("\nConnect Peers")
            bitcoinWallet.connectPeers()
            print("\nStart Syncing")
            bitcoinWallet.startSyncing()
            
            
            
            
//            print("\n------------------------- Litecoin ----------------------------\n")
//            // Litecoin : 2
//            let litecoinWallet = NRLWallet(seed: seed, network: .main(.litecoin))
//            litecoinWallet.generateExternalKeyPair(at: 0)
//
//            privateKey = litecoinWallet.getWIF()
//            publicKey = litecoinWallet.getPublicKey()
//            address = litecoinWallet.getAddress()
//
//            print("\nLitecoinWallet private key = \(privateKey)")
//            print("LitecoinWallet public key = \(publicKey)")
//            print("LitecoinWallet address = \(address)")
//
//            print("\n------------------------- Stellar ----------------------------\n")
//            // Stellar : 148
//            let stellarWallet = NRLWallet(seed: seed, network: .main(.stellar))
//            stellarWallet.generateExternalKeyPair(at: 0)
//
//            privateKey = stellarWallet.getWIF()
//            publicKey = stellarWallet.getPublicKey()
//            address = stellarWallet.getAddress()
//
//            print("\n stellarWallet private key = \(privateKey)")
//             print("stellarWallet public key = \(publicKey)")
//            print("stellarWallet address = \(address)")
//
//            print("\n-----------------------------------------------------\n")

        } catch {
            print(error)
        }
    }
}
