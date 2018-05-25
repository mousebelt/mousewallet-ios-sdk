//
//  NRLPrivateKey.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public struct NRLPrivateKey {
    public let raw: Data
    public let chainCode: Data
    private let depth: UInt8
    private let fingerprint: UInt32
    private let childIndex: UInt32
    private let coin: NRLCoin
    
    //Fixeds: seed key is different to coin types.
    init(seed: Data, privkey: Data, coin: NRLCoin) {
        self.coin = coin
        self.raw = privkey[0..<32]
        self.chainCode = privkey[32..<64]
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
    }

    private init(nrlPrivateKey: Data, chainCode: Data, depth: UInt8, fingerprint: UInt32, index: UInt32, coin: NRLCoin) {
        self.raw = nrlPrivateKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = index
        self.coin = coin
    }

    public func nrlPublicKey() -> NRLPublicKey {
        return NRLPublicKey(nrlPrivateKey: self, chainCode: chainCode, coin: self.coin, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
    }

    //this is for bitcoin case
    public func extended() -> String {
        var extendedPrivateKeyData = Data()
        extendedPrivateKeyData += self.coin.network.privateKeyPrefix.bigEndian
        extendedPrivateKeyData += depth.littleEndian
        extendedPrivateKeyData += fingerprint.littleEndian
        extendedPrivateKeyData += childIndex.littleEndian
        extendedPrivateKeyData += chainCode
        extendedPrivateKeyData += UInt8(0)
        extendedPrivateKeyData += raw
        let checksum = Crypto.doubleSHA256(extendedPrivateKeyData).prefix(4)
        return Base58.encode(extendedPrivateKeyData + checksum)
    }

    internal func derived(at index: UInt32, hardens: Bool = false) throws -> NRLPrivateKey {
        guard (0x80000000 & index) == 0 else {
            fatalError("Invalid index \(index)")
        }

        let keyDeriver = KeyDerivation(
            privateKey: raw,
            publicKey: nrlPublicKey().raw,
            chainCode: chainCode,
            depth: depth,
            fingerprint: fingerprint,
            childIndex: childIndex
        )

        guard let derivedKey = keyDeriver.derived(at: index, hardened: hardens, curveOrder: coin.curve) else {
            throw NRLWalletSDKError.keyDerivateionFailed
        }

        return NRLPrivateKey(
            nrlPrivateKey: derivedKey.privateKey!,
            chainCode: derivedKey.chainCode,
            depth: derivedKey.depth,
            fingerprint: derivedKey.fingerprint,
            index: derivedKey.childIndex,
            coin: self.coin
        )
    }
    

    public func derived_Ed25519(at index: UInt32) -> NRLPrivateKey {
        let edge: UInt32 = 0x80000000
        guard (edge & index) == 0 else { fatalError("Invalid index") }
        
        var data = Data()
        data += UInt8(0)
        data += raw
        
        let derivingIndex = edge + index
        data += derivingIndex.bigEndian
        
        let digest = HDCrypto.HMACSHA512(key: chainCode, data: data)
        let factor = BInt(data: digest[0..<32])
        
        let derivedPrivateKey = factor.data
        let derivedChainCode = digest[32..<64]
        
        return NRLPrivateKey(
            nrlPrivateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            depth: depth + 1,
            fingerprint: 0,
            index: 0,
            coin: self.coin
        )
    }
}
