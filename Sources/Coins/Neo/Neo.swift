//
//  Neo.swift
//  NRLWalletSDK
//
//  Created by David Bala on 17/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import Neoutils

class NRLNeo : NRLCoin{
    init(seed: Data) {
        super.init(seed: seed,
                   network: .main(.neo),
                   coinType: 888,
                   seedKey: "Nist256p1 seed",
                   curve: "ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551")
    }
    
    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        var error: NSError?
        let wallet = NeoutilsGenerateFromPrivateKey(privateKey.toHexString(), &error)
        let publickey = wallet?.publicKey()
//        print("public key generated: \(publickey?.toHexString() ?? "")")
        return publickey!
    }
    
    //in neo should use secp256r1. (it was secp256k1 in ethereum)
    override func generateAddress() {
        var error: NSError?
        let wallet = NeoutilsGenerateFromPrivateKey(self.pathPrivateKey?.raw.toHexString(), &error)
        self.wif = (wallet?.wif())!
        self.address = (wallet?.address())!
    }
    
    override func generateExternalKeyPair(at index: UInt32) throws {
        try super.generateExternalKeyPair(at: index)
        generateAddress()
    }
}

