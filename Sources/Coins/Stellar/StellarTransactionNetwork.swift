//
//  StellarTransactionNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 15/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper


public class StellarTxDetailResponse: Mappable, Equatable {
    public var id: String?
    public var paging_token: String?
    public var transaction_hash: String?
    public var created_at: String?
    public var source_account: String?
    public var type: String?
    public var type_i: UInt?
    public var asset_type: String?
    public var asset_code: String?
    public var asset_issuer: String?
    public var from: String?
    public var to: String?
    public var amount: String?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        id                      <- map["id"]
        paging_token            <- map["paging_token"]
        transaction_hash        <- map["transaction_hash"]
        created_at              <- map["created_at"]
        source_account          <- map["source_account"]
        type                    <- map["type"]
        type_i                  <- map["type_i"]
        asset_type              <- map["asset_type"]
        asset_code              <- map["asset_code"]
        asset_issuer            <- map["asset_issuer"]
        from                    <- map["from"]
        to                      <- map["to"]
        amount                  <- map["amount"]
    }
    
    public static func == (lhs: StellarTxDetailResponse, rhs: StellarTxDetailResponse) -> Bool {
        return lhs.id == rhs.id &&
            lhs.transaction_hash == rhs.transaction_hash
    }
}

public class StellarGetTransactionsResponse: Mappable {
    public var next: String?
    public var prev: String?
    public var result: [StellarTxDetailResponse]?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        next         <- map["next"]
        prev         <- map["prev"]
        result        <- map["result"]
    }
}


public class StellarSendSignedTransactionResponse: Mappable, Equatable {
    public var result_meta_xdr: String?
    public var result_xdr: String?
    public var hash: String?
    public var ledger: String?
    public var envelope_xdr: String?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        result_meta_xdr         <- map["result_meta_xdr"]
        result_xdr              <- map["result_xdr"]
        hash                    <- map["hash"]
        ledger                  <- map["ledger"]
        envelope_xdr            <- map["envelope_xdr"]
    }
    
    public static func == (lhs: StellarSendSignedTransactionResponse, rhs: StellarSendSignedTransactionResponse) -> Bool {
        return lhs.hash == rhs.hash &&
            lhs.ledger == rhs.ledger
    }
}

