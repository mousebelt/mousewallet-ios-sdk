//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

class NRLBitcoin : NRLCoin{
    init(seed: Data) {
        super.init(seed: seed,
                   network: .main(.bitcoin),
                   coinType: 0,
                   seedKey: "Bitcoin seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }

    //in neo should use secp256r1. (it was secp256k1 in ethereum)
    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        let publicKey = Crypto.generatePublicKey(data: privateKey, compressed: true)
        return publicKey;
    }
    
    override func generateAddress() {
        let publicKey = Crypto.generatePublicKey(data: (self.pathPrivateKey?.raw)!, compressed: false)
        self.address = Address.generateAddress(publicKey: publicKey)
        self.wif = self.pathPrivateKey?.raw.toHexString()
    }
}
