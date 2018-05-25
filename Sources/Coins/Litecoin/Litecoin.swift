//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

class NRLLitecoin : NRLCoin{
    let isTest: Bool;
    init(seed: Data, fTest: Bool) {
        self.isTest = fTest;
        var network: Network = .main(.litecoin)
        if (fTest) {
            network = .test(.litecoin)
        }
        
        let cointype = network.coinType
        
        super.init(seed: seed,
                   network: network,
                   coinType: cointype,
                   seedKey: "Bitcoin seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }
    
    //from https://github.com/onmyway133/AddressGenerator
    var pubkeyhash: UInt8 {
        if (self.isTest) {
            return 0x6f //??? maybe no testnet in litecoin
        }
        return 0x30
    }
    var privatekey: UInt8 {
        if (self.isTest) {
            return 0xef//??? maybe no testnet in litecoin
        }
        return 0xb0
    }
    var scripthash: UInt8 {
        if (self.isTest) {
            return 0xc4
        }
        return 0x05
    }
    
    var magic: UInt32 {
        if (self.isTest) {
            return 0x0b110907
        }
        return 0xf9beb4d9
    }
    
    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        let publicKey = Crypto.generatePublicKey(data: privateKey, compressed: true)
        return publicKey;
    }
    
    //compressed is only for keys start with L, K
    //https://github.com/pointbiz/bitaddress.org/releases
    public func toWIF(privatekey: Data, compressed: Bool = false) -> String {
        var data = Data([self.privatekey]) + privatekey
        if (compressed) {
            data = data + Data([0x01]);
        }
        let checksum = Crypto.doubleSHA256(data).prefix(4)
        return Base58.encode(data + checksum)
    }
    
    func publicKeyHashToAddress(_ hash: Data) -> String {
        let checksum = Crypto.doubleSHA256(hash).prefix(4)
        let address = Base58.encode(hash + checksum)
        return address
    }
    
    func toAddress(publickkey: Data) -> String {
        let hash = Data([self.pubkeyhash]) + Crypto.hash160(publickkey)
        return publicKeyHashToAddress(hash)
    }
    
    override func generateAddress() {
        self.address = toAddress(publickkey: (self.pathPrivateKey?.nrlPublicKey().raw)!);
        self.wif = toWIF(privatekey: (self.pathPrivateKey?.raw)!, compressed: true);
    }
}

