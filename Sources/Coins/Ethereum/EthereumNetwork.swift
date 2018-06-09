//
//  EthereumNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 08/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper

class TxDetailResponse: Mappable, Equatable {
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
    
    static func == (lhs: TxDetailResponse, rhs: TxDetailResponse) -> Bool {
        return lhs.blockHash == rhs.blockHash &&
            lhs.transactionIndex == rhs.transactionIndex &&
            lhs.hash == rhs.hash
    }
}

class TransactionResponse: Mappable, Equatable {
    var total: UInt?
    var result: [TxDetailResponse]?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        total         <- map["total"]
        result        <- map["result"]
    }
    
    static func == (lhs: TransactionResponse, rhs: TransactionResponse) -> Bool {
        return lhs.total == rhs.total &&
            lhs.result == rhs.result
    }
}

class GetBalanceResponse: Mappable, Equatable {
    var balance: String?
    var address: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        balance        <- map["balance"]
        address        <- map["address"]
    }
    
    static func == (lhs: GetBalanceResponse, rhs: GetBalanceResponse) -> Bool {
        return lhs.address == rhs.address
    }
}

class SendSignedTransactionResponse: Mappable, Equatable {
    var blockNumber: UInt?
    var status: Bool?
    var to: String?
    var transactionHash: String?
    var blockHash: String?
    var from: String?
    var contractAddress: String?
    var logsBloom: String?
    var logs: [String]?
    var gasUsed: UInt?
    var cumulativeGasUsed: UInt?
    var transactionIndex: UInt?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        blockNumber         <- map["blockNumber"]
        status              <- map["status"]
        to                  <- map["to"]
        transactionHash     <- map["transactionHash"]
        blockHash           <- map["blockHash"]
        from                <- map["from"]
        contractAddress     <- map["contractAddress"]
        logsBloom           <- map["logsBloom"]
        logs                <- map["logs"]
        gasUsed             <- map["gasUsed"]
        cumulativeGasUsed   <- map["cumulativeGasUsed"]
        transactionIndex    <- map["transactionIndex"]
    }
    
    static func == (lhs: SendSignedTransactionResponse, rhs: SendSignedTransactionResponse) -> Bool {
        return lhs.transactionHash == rhs.transactionHash &&
            lhs.blockHash == rhs.blockHash
    }
}


