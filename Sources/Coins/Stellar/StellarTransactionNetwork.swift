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
    var id: String?
    var paging_token: String?
    var hash: String?
    var ledger: UInt?
    var created_at: String?
    var source_account: String?
    var source_account_sequence: String?
    var fee_paid: UInt?
    var operation_count: UInt?
    var envelope_xdr: String?
    var result_xdr: String?
    var result_meta_xdr: String?
    var fee_meta_xdr: String?
    var signatures: [String]?
    
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        id           <- map["id"]
        paging_token         <- map["paging_token"]
        hash                <- map["hash"]
        ledger                  <- map["ledger"]
        created_at                 <- map["created_at"]
        source_account            <- map["source_account"]
        source_account_sequence                <- map["source_account_sequence"]
        fee_paid               <- map["fee_paid"]
        operation_count               <- map["operation_count"]
        envelope_xdr    <- map["envelope_xdr"]
        result_xdr               <- map["result_xdr"]
        result_meta_xdr                   <- map["result_meta_xdr"]
        fee_meta_xdr                   <- map["fee_meta_xdr"]
        signatures                   <- map["signatures"]
    }
    
    public static func == (lhs: StellarTxDetailResponse, rhs: StellarTxDetailResponse) -> Bool {
        return lhs.id == rhs.id &&
            lhs.ledger == rhs.ledger &&
            lhs.hash == rhs.hash
    }
}

public class StellarGetTransactionsResponse: Mappable {
    var next: String?
    var prev: String?
    var result: [StellarTxDetailResponse]?
    
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
    var result_meta_xdr: String?
    var result_xdr: String?
    var hash: String?
    var ledger: String?
    var envelope_xdr: String?
    
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

