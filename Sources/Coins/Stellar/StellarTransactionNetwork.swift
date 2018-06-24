//
//  StellarTransactionNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 15/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper


class StellarTxDetailResponse: Mappable, Equatable {
    var blockHash: String?
    var blockNumber: UInt?
    var from: String?
    var to: String?
    var gas: UInt?
    var gasPrice: String?
    var hash: String?
    var input: String?
    var nonce: UInt?
    var transactionIndex: UInt?
    var value: UInt?
    var v: String?
    var r: String?
    var s: String?
    
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        blockHash           <- map["blockHash"]
        blockNumber         <- map["blockNumber"]
        from                <- map["from"]
        to                  <- map["to"]
        gas                 <- map["gas"]
        gasPrice            <- map["gasPrice"]
        hash                <- map["hash"]
        input               <- map["input"]
        nonce               <- map["nonce"]
        transactionIndex    <- map["transactionIndex"]
        value               <- map["value"]
        v                   <- map["v"]
        r                   <- map["r"]
        s                   <- map["s"]
    }
    
    static func == (lhs: StellarTxDetailResponse, rhs: StellarTxDetailResponse) -> Bool {
        return lhs.blockHash == rhs.blockHash &&
            lhs.transactionIndex == rhs.transactionIndex &&
            lhs.hash == rhs.hash
    }
}

class StellarGetTransactionsResponse: Mappable, Equatable {
    var total: UInt?
    var result: [ETHTxDetailResponse]?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        total         <- map["total"]
        result        <- map["result"]
    }
    
    static func == (lhs: StellarGetTransactionsResponse, rhs: StellarGetTransactionsResponse) -> Bool {
        return lhs.total == rhs.total &&
            lhs.result == rhs.result
    }
}


class StellarSendSignedTransactionResponse: Mappable, Equatable {
    var result_meta_xdr: String?
    var result_xdr: String?
    var hash: String?
    var ledger: String?
    var envelope_xdr: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        result_meta_xdr         <- map["result_meta_xdr"]
        result_xdr              <- map["result_xdr"]
        hash                    <- map["hash"]
        ledger                  <- map["ledger"]
        envelope_xdr            <- map["envelope_xdr"]
    }
    
    static func == (lhs: StellarSendSignedTransactionResponse, rhs: StellarSendSignedTransactionResponse) -> Bool {
        return lhs.hash == rhs.hash &&
            lhs.ledger == rhs.ledger
    }
}

