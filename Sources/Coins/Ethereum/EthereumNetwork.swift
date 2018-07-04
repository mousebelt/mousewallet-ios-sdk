//
//  EthereumNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 08/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper

public class ETHTxDetailResponse: Mappable, Equatable {
    public var blockHash: String?
    public var blockNumber: UInt?
    public var from: String?
    public var to: String?
    public var gas: UInt?
    public var gasPrice: String?
    public var hash: String?
    public var input: String?
    public var nonce: UInt?
    public var transactionIndex: UInt?
    public var value: UInt?
    public var v: String?
    public var r: String?
    public var s: String?
    
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
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
    
    public static func == (lhs: ETHTxDetailResponse, rhs: ETHTxDetailResponse) -> Bool {
        return lhs.blockHash == rhs.blockHash &&
            lhs.transactionIndex == rhs.transactionIndex &&
            lhs.hash == rhs.hash
    }
}

public class ETHGetTransactionsResponse: Mappable, Equatable {
    public var total: UInt?
    public var result: [ETHTxDetailResponse]?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        total         <- map["total"]
        result        <- map["result"]
    }
    
    public static func == (lhs: ETHGetTransactionsResponse, rhs: ETHGetTransactionsResponse) -> Bool {
        return lhs.total == rhs.total &&
            lhs.result == rhs.result
    }
}

public class ETHGetBalanceMap: Mappable, Equatable {
    public var balance: String?
    public var symbol: String?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        balance       <- map["balance"]
        symbol        <- map["symbol"]
    }
    
    public static func == (lhs: ETHGetBalanceMap, rhs: ETHGetBalanceMap) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

public class ETHGetBalanceResponse: Mappable {
    public var balances: [ETHGetBalanceMap]?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        balances        <- map["balances"]
    }

}

public class ETHSendSignedTransactionResponse: Mappable, Equatable {
    public var blockNumber: UInt?
    public var status: Bool?
    public var to: String?
    public var transactionHash: String?
    public var blockHash: String?
    public var from: String?
    public var contractAddress: String?
    public var logsBloom: String?
    public var logs: [String]?
    public var gasUsed: UInt?
    public var cumulativeGasUsed: UInt?
    public var transactionIndex: UInt?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
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
    
    public static func == (lhs: ETHSendSignedTransactionResponse, rhs: ETHSendSignedTransactionResponse) -> Bool {
        return lhs.transactionHash == rhs.transactionHash &&
            lhs.blockHash == rhs.blockHash
    }
}


