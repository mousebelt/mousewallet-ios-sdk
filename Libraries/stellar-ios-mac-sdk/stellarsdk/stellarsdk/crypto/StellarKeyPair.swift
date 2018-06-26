//
//  StellarKeyPair.swift
//  stellarsdk
//
//  Created by Razvan Chelemen on 29/01/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import ed25519C

/// Holds a Stellar keypair.
public final class StellarKeyPair {
    public let publicKey: StellarPublicKey
    public let privateKey: StellarPrivateKey?
    public private(set) var seed:StellarSeed?

    /// Human readable Stellar account ID.
    public var accountId: String {
        get {
            return publicKey.accountId
        }
    }
    /// Human readable Stellar secret seed.
    public var secretSeed: String! {
        get {
            return seed?.secret
        }
    }
    
    /// Generates a random Stellar keypair.
    open static func generateRandomKeyPair() throws -> StellarKeyPair {
        let seed = try StellarSeed()
        let keyPair = StellarKeyPair(seed: seed)
        
        return keyPair
    }
    
    /// Creates a new StellarKeyPair from the given public and private keys.
    ///
    /// - Parameter publicKey: The public key
    /// - Parameter publicKey: The private key. Optional, if nil creates a new StellarKeyPair without a private key.
    ///
    public init(publicKey: StellarPublicKey, privateKey: StellarPrivateKey?) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    /// Creates a new Stellar StellarKeyPair from a Stellar account ID. The new StellarKeyPair is without a private key.
    ///
    /// - Parameter accountId: The Stellar account ID.
    ///
    public convenience init(accountId: String) throws {
        let publicKeyFromAccountId = try StellarPublicKey(accountId: accountId)
        self.init(publicKey: publicKeyFromAccountId, privateKey:nil)
    }
    
    /// Creates a new Stellar keypair from a Stellar secret seed. The new StellarKeyPair contains public and private key.
    ///
    /// - Parameter secretSeed: the Stellar secret seed.
    public convenience init(secretSeed: String) throws {
        let seedFromSecret = try StellarSeed(secret:secretSeed)
        self.init(seed: seedFromSecret)
    }
    
    /// Creates a new StellarKeyPair without a private key. Useful e.g. to simply verify a signature from a given public address
    ///
    /// - Parameter publicKey: The public key
    ///
    public convenience init(publicKey: StellarPublicKey)
    {
        self.init(publicKey:publicKey, privateKey:nil)
    }
    
    /// Creates a new Stellar keypair from a seed object. The new StellarKeyPair contains public and private key.
    ///
    /// - Parameter seed: the seed object
    ///
    public convenience init(seed: StellarSeed) {
        
        var pubBuffer = [UInt8](repeating: 0, count: 32)
        var privBuffer = [UInt8](repeating: 0, count: 64)

        privBuffer.withUnsafeMutableBufferPointer { priv in
            pubBuffer.withUnsafeMutableBufferPointer { pub in
                seed.bytes.withUnsafeBufferPointer { seed in
                    ed25519_create_keypair(pub.baseAddress,
                                           priv.baseAddress,
                                           seed.baseAddress)
                }
            }
        }

        self.init(publicKey: StellarPublicKey(unchecked: pubBuffer),
                  privateKey: StellarPrivateKey(unchecked: privBuffer))
        
        self.seed = seed
    }
    
    /// Creates a new Stellar keypair from a public key byte array and a private key byte array.
    ///
    /// - Parameter publicKey: the public key byte array. Must have a lenght of 32.
    /// - Parameter privateKey: the private key byte array. Must have a lenght of 64.
    ///
    /// - Throws Ed25519Error.invalidPublicKeyLength if the lenght of the given byte array != 32
    /// - Throws Ed25519Error.invalidPrivateKeyLength if the lenght of the given byte array != 64
    ///
    public convenience init(publicKey: [UInt8], privateKey: [UInt8]) throws {
        let pub = try StellarPublicKey(publicKey)
        let priv = try StellarPrivateKey(privateKey)
        self.init(publicKey: pub, privateKey: priv)
    }
    
    public static func fromXDRSignerKey(_ publicKey: StellarPublicKey) -> SignerKeyXDR {
         var seedBuffer = [UInt8](repeating: 0, count: 32)
         var privBuffer = [UInt8](repeating: 0, count: 64)
         var pubBuffer = [UInt8](publicKey.bytes)
        
         privBuffer.withUnsafeMutableBufferPointer { priv in
            pubBuffer.withUnsafeMutableBufferPointer { pub in
                seedBuffer.withUnsafeMutableBufferPointer { seed in
                    ed25519_create_keypair(pub.baseAddress,
                                           priv.baseAddress,
                                           seed.baseAddress)
                }
            }
        }
     
        return SignerKeyXDR.ed25519(WrappedData32(Data(bytes: pubBuffer)))
     }
    
    /// Sign the provided data with the keypair's private key.
    ///
    /// - Parameter message: The data to sign.
    ///
    /// - Returns signed bytes, "empty" byte array containing only 0 if the private key for this keypair is null.
    ///
    public func sign(_ message: [UInt8]) -> [UInt8] {
        
        var signature = [UInt8](repeating: 0, count: 64)
        
        if (privateKey == nil) { return signature}
        
        signature.withUnsafeMutableBufferPointer { signature in
            privateKey?.bytes.withUnsafeBufferPointer { priv in
                publicKey.bytes.withUnsafeBufferPointer { pub in
                    message.withUnsafeBufferPointer { msg in
                        ed25519_sign(signature.baseAddress,
                                     msg.baseAddress,
                                     message.count,
                                     pub.baseAddress,
                                     priv.baseAddress)
                    }
                }
            }
        }
        
        return signature
    }
    
    /// Sign the provided data with the keypair's private key and returns the DecoratedSignatureXDR
    ///
    /// - Parameter data: data to be signed
    ///
    /// - Returns the DecoratedSignatureXDR object
    ///
    public func signDecorated(_ message: [UInt8]) -> DecoratedSignatureXDR {
        var signatureBytes = sign(message)
        let signatureData = Data(bytes: &signatureBytes, count: signatureBytes.count)
        var publicKeyData = publicKey.bytes
        let hint = Data(bytes: &publicKeyData, count: publicKeyData.count).suffix(4)
        let decoratedSignature = DecoratedSignatureXDR(hint: WrappedData4(hint) , signature: signatureData)
        
        return decoratedSignature
    }

    ///  Verify the provided data and signature match this keypair's public key.
    ///
    /// - Parameter signature: The signature. Byte array must have a lenght of 64.
    /// - Parameter message: The data that was signed.
    ///
    /// - Returns: True if they match, false otherwise.
    ///
    /// - Throws: Ed25519Error.invalidSignatureLength if the signature length is not 64
    ///
    public func verify(signature: [UInt8], message: [UInt8]) throws -> Bool {
        return try publicKey.verify(signature: signature, message: message)
    }
}
