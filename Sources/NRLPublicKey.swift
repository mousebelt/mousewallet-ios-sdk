//
//  NRLPublicKey.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public struct NRLPublicKey {
    public let raw: Data
    public let chainCode: Data
    private let depth: UInt8
    private let fingerprint: UInt32
    private let childIndex: UInt32
    private let network: Network

    private let nrlPrivateKey: NRLPrivateKey

    public init(nrlPrivateKey: NRLPrivateKey, chainCode: Data, network: Network, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.raw = Crypto.generatePublicKey(data: nrlPrivateKey.raw, compressed: true)
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
        self.network = network
        self.nrlPrivateKey = nrlPrivateKey
    }
    
    public func extended() -> String {
        var extendedPublicKeyData = Data()
        extendedPublicKeyData += network.publicKeyPrefix.bigEndian
        extendedPublicKeyData += depth.littleEndian
        extendedPublicKeyData += fingerprint.littleEndian
        extendedPublicKeyData += childIndex.littleEndian
        extendedPublicKeyData += chainCode
        extendedPublicKeyData += raw
        let checksum = Crypto.doubleSHA256(extendedPublicKeyData).prefix(4)
        return Base58.encode(extendedPublicKeyData + checksum)
    }
}
