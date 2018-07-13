//
//  NeoTransactionNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 26/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper

public class NeoValueOutMap: Mappable {
    public var n: Int?
    public var asset: String?
    public var value: String?
    public var address: String?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        n         <- map["n"]
        asset     <- map["asset"]
        value     <- map["value"]
        value     <- map["value"]
    }
}

public class NeoValueInMap: Mappable {
    public var transactionID: String?
    public var valueOut: Int?
    public var address: NeoValueOutMap?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        transactionID   <- map["txid"]
        valueOut        <- map["vout"]
        address         <- map["address"]

    }
}

public class NeoScriptMap: Mappable {
    public var invocation: String?
    public var verification: String?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        invocation          <- map["invocation"]
        verification        <- map["verification"]
    }
}
    
public class NeoTransactionDetailMap: Mappable {
    public var transactionID: String?
    public var size: Int64?
    public var type: String?
    public var version: Int64?
    // var attributes: [] //Need to handle this, not really sure what kind of objects it can give bakc
    public var valueIns: [NeoValueInMap]?
    public var systemFee: String?
    public var networkFee: String?

    public var valueOuts: [NeoValueOutMap]?
    public var scripts: [NeoScriptMap]?
    public var blockhash: String?
    public var confirmations: UInt64?
    public var blocktime: UInt64?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        valueOuts       <- map["vout"]
        scripts         <- map["scripts"]
        blockhash       <- map["blockhash"]
        systemFee       <- map["sys_fee"]
        size            <- map["size"]
        type            <- map["type"]
        confirmations   <- map["confirmations"]
        networkFee      <- map["net_fee"]
        transactionID   <- map["txid"]
        version         <- map["version"]
        blocktime       <- map["blocktime"]
        valueIns        <- map["vin"]
    }
}

public class NeoTransactionsMap: Mappable {
    public var total: String?
    public var result: [NeoTransactionDetailMap]?
    
    public required init?(map: Map) {
    }
    
    // Mappable
    public func mapping(map: Map) {
        total        <- map["total"]
        result       <- map["result"]
    }
}

public class NeoUTXOMap: Mappable {
    public var txid: String?
    public var index: Int?
    public var value: Decimal?
    public var asset: String?
    public var createdAtBlock: Int?
    
    public required init?(map: Map) {
    }
    
    // Mappable
    public func mapping(map: Map) {
        txid                <- map["txid"]
        index               <- map["index"]
        value               <- map["amount"]
        asset               <- map["asset"]
        createdAtBlock      <- map["createdAtBlock"]
    }
}

public class NeoUTXOsResponse: Mappable {
    public var utxos: [NeoUTXOMap]?
    
    public required init?(map: Map) {
    }
    
    // Mappable
    public func mapping(map: Map) {
        utxos        <- map["utxos"]
    }
}



