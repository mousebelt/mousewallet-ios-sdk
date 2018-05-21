//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

class NRLEthereum : NRLCoin{
    init(seed: Data) {
        super.init(seed: seed,
                   network: .main(.ethereum),
                   coinType: 60,
                   seedKey: "Bitcoin seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }

    //in neo should use secp256r1. (it was secp256k1 in ethereum)
    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        let publicKey = Crypto.generatePublicKey(data: privateKey, compressed: true)
//        print("public key generated: \(publickey?.toHexString() ?? "")")
        return publicKey;
    }
    
    override func generateAddress() {
        self.address = ENRLEthereumUtils.publicToAddressStr(self.pathPrivateKey!.nrlPublicKey().raw)!
        self.wif = self.pathPrivateKey?.raw.toHexString()
    }
    
    override func generateExternalKeyPair(at index: UInt32) throws {
        try super.generateExternalKeyPair(at: index)
        generateAddress()
    }
}
