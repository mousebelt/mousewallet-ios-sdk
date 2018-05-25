//
//  NRLWalletSDKError.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public enum NRLWalletSDKError: Error {
    case keyDerivateionFailed
    public enum RequestError: Error {
        case invalidURL
        case invalidParameters(Any)
    }
    
    public enum ResponseError: Error {
        case jsonrpcError(JSONRPCError)
        case connectionError(Error)
        case unexpected(Error)
        case unacceptableStatusCode(Int)
        case noContentProvided
    }
    
    public enum CryptoError: Error {
        case failedToSign
        case failedToEncode(Any)
        case keyDerivateionFailed
    }
    
    case requestError(RequestError)
    case responseError(ResponseError)
    case cryptoError(CryptoError)
}

public enum Ed25519Error: Error {
    case seedGenerationFailed
    case invalidSeed
    case invalidSeedLength
    case invalidScalarLength
    case invalidPublicKey
    case invalidPublicKeyLength
    case invalidPrivateKey
    case invalidPrivateKeyLength
    case invalidSignatureLength
}
