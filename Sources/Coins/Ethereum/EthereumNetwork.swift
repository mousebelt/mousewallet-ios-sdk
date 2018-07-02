//
//  EthereumNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 08/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper

class ETHTxDetailResponse: Mappable, Equatable {
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
    
    static func == (lhs: ETHTxDetailResponse, rhs: ETHTxDetailResponse) -> Bool {
        return lhs.blockHash == rhs.blockHash &&
            lhs.transactionIndex == rhs.transactionIndex &&
            lhs.hash == rhs.hash
    }
}

class ETHGetTransactionsResponse: Mappable, Equatable {
    var total: UInt?
    var result: [ETHTxDetailResponse]?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        total         <- map["total"]
        result        <- map["result"]
    }
    
    static func == (lhs: ETHGetTransactionsResponse, rhs: ETHGetTransactionsResponse) -> Bool {
        return lhs.total == rhs.total &&
            lhs.result == rhs.result
    }
}

class ETHGetBalanceMap: Mappable, Equatable {
    var balance: String?
    var symbol: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        balance       <- map["balance"]
        symbol        <- map["symbol"]
    }
    
    static func == (lhs: ETHGetBalanceMap, rhs: ETHGetBalanceMap) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

class ETHGetBalanceResponse: Mappable {
    var balances: [ETHGetBalanceMap]?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        balances        <- map["balances"]
    }

}

class ETHSendSignedTransactionResponse: Mappable, Equatable {
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
    
    static func == (lhs: ETHSendSignedTransactionResponse, rhs: ETHSendSignedTransactionResponse) -> Bool {
        return lhs.transactionHash == rhs.transactionHash &&
            lhs.blockHash == rhs.blockHash
    }
}


