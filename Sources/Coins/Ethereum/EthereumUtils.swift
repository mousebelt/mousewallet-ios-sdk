//
//  utils.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

// NOTE: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
public struct EIP55 {
    public static func encode(_ data: Data) -> String {
        let address = data.toHexString()
        let hash = Crypto.hashSHA3_256(address.data(using: .ascii)!).toHexString()
        
        return zip(address, hash)
            .map { a, h -> String in
                switch (a, h) {
                case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
                    return String(a)
                case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
                    return String(a).uppercased()
                default:
                    return String(a).lowercased()
                }
            }
            .joined()
    }
}

/// Represents an address
public struct Address {
    
    /// Address in data format
    public let data: Data
    
    /// Address in string format, EIP55 encoded
    public let string: String
    
    public init(data: Data) {
        self.data = data
        self.string = "0x" + EIP55.encode(data)
    }
    
    public init(string: String) {
        self.data = Data(hex: string.stripHexPrefix())
        self.string = string
    }
    
    /// generates address from its public key
    ///
    /// - Returns: address in string format
    public static func generateAddress(publicKey: Data) -> String {
        return Address(data: addressDataFromPublicKey(publicKey: publicKey)).string
    }
    
    /// Address data generated from public key in data format
    static func addressDataFromPublicKey(publicKey: Data) -> Data {
        return Crypto.hashSHA3_256(publicKey.dropFirst()).suffix(20)
    }
}
