//
//  Crypto.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import NRLWalletSDK.Private

//from https://github.com/yuzushioh/EthereumKit
public final class Crypto {
    public static func HMACSHA512(key: Data, data: Data) -> Data {
        return CryptoHash.hmacsha512(data, key: key)
    }

    public static func PBKDF2SHA512(_ password: Data, salt: Data) -> Data {
        return PKCS5.pbkdf2(password, salt: salt, iterations: 2048, keyLength: 64)
    }

    public static func doubleSHA256(_ data: Data) -> Data {
        return data.sha256().sha256()
    }

    public static func generatePublicKey(data: Data, compressed: Bool) -> Data {
        return Secp256k1.generatePublicKey(withPrivateKey: data, compression: compressed)
    }
    
    /// Returns SHA3 256-bit (32-byte) hash of the data
    ///
    /// - Parameter data: data to be hashed
    /// - Returns: 256-bit (32-byte) hash
    public static func hashSHA3_256(_ data: Data) -> Data {
        return data.sha3(.keccak256)
    }
}
