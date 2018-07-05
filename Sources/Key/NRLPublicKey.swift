//
//  NRLPublicKey.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//
import Neoutils
public struct NRLPublicKey {
    public let raw: Data
    public let chainCode: Data
    private let depth: UInt8
    private let fingerprint: UInt32
    private let childIndex: UInt32
    private let coin: NRLCoin

    private let nrlPrivateKey: NRLPrivateKey

    init(nrlPrivateKey: NRLPrivateKey, chainCode: Data, coin: NRLCoin, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.coin = coin
        do {
            self.raw = try! self.coin.generatePublickeyFromPrivatekey(privateKey: nrlPrivateKey.raw);
        } catch {
            self.raw = Data()
        }
        
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
        self.nrlPrivateKey = nrlPrivateKey
    }
    
    init(pubkey: Data, nrlPrivateKey:NRLPrivateKey, coin: NRLCoin) {
        self.coin = coin
        self.raw = pubkey;
        self.chainCode = Data()
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
        self.nrlPrivateKey = nrlPrivateKey
    }

    //this is for bitcoin case
    public func extended() -> String {
        var extendedPublicKeyData = Data()
        extendedPublicKeyData += self.coin.network.publicKeyPrefix.bigEndian
        extendedPublicKeyData += depth.littleEndian
        extendedPublicKeyData += fingerprint.littleEndian
        extendedPublicKeyData += childIndex.littleEndian
        extendedPublicKeyData += chainCode
        extendedPublicKeyData += raw
        let checksum = Crypto.doubleSHA256(extendedPublicKeyData).prefix(4)
        return Base58.encode(extendedPublicKeyData + checksum)
    }
}
