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
        case unexpected(Any)
    }
    
    public enum ResponseError: Error {
        case jsonrpcError(JSONRPCError)
        case connectionError(Error)
        case unacceptableStatusCode(Int)
        case noContentProvided
        case resourceMissing(Any)
        case unexpected(Any)
    }
    
    public enum CryptoError: Error {
        case failed(Any)
        case failedToSign
        case failedToCreateTransaction
        case keyDerivateionFailed
    }
    
    public enum SyncError: Error {
        case failedToConnect
    }

    public enum TransactionError: Error {
        case parameterError
        case publishError
        case transactionFailed(Error)
    }
    
    public enum AccountError: Error {
        case keyError
        case addressError
        case seqnumError
        case notCreated
        case failed(Any)
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

