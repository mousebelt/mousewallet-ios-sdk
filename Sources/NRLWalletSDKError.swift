//
//  NRLWalletSDKError.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public enum NRLWalletSDKError: Error {
    public enum RequestError: Error {
        case invalidURL
        case invalidParameters(Any)
    }
    
    public enum ResponseError: Error {
        case jsonrpcError(JSONRPCError)
        case connectionError(Error)
        case unexpected(Any)
        case unacceptableStatusCode(Int)
        case noContentProvided
    }
    
    public enum CryptoError: Error {
        case failedToSign
        case failedToEncode(Any)
        case keyDerivateionFailed
        case seedGenerationFailed
        case invalidSeed
        case invalidSeedLength
        case invalidPublicKey
        case invalidPublicKeyLength
        case invalidPrivateKey
        case invalidPrivateKeyLength
        case invalidSignatureLength
    }
    
    public enum SyncError: Error {
        case failedToConnect
    }

    public enum TransactionError: Error {
        case parameterError
        case publishError
        case transactionFailed(Error)
        case signFailed(Error)
    }
    
    public enum AccountError: Error {
        case keyError
        case addressError
        case seqnumError
    }
    
    case nrlSuccess
    case requestError(RequestError)
    case responseError(ResponseError)
    case cryptoError(CryptoError)
    case syncError(SyncError)
    case transactionError(TransactionError)
    case accountError(AccountError)
    case malformedData
}

