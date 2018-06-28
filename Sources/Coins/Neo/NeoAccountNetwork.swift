//
//  NeoNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 25/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper

public class NeoTokenMapp: Mappable {
    public var name:String?     //token name
    public var symbol:String?   //token symbol
    public var asset:String?    //token address
    public var type:String?

    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        name       <- map["name"]
        symbol     <- map["ticker"]
        asset      <- map["asset"]
        type       <- map["type"]
    }
}

public class NeoAssetMap: Mappable {
    public var asset:String?
    public var value:Decimal?
    public var symbol:String?
    public var token:NeoTokenMapp?
    
    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        asset        <- map["asset"]
        value        <- map["value"]
        symbol       <- map["ticker"]
        token        <- map["token"]
    }
}

public class NeoGetBalanceResponse: Mappable, Equatable {
    
    public var address:String?
    public var n_tx: UInt?
    public var balance:[NeoAssetMap]?

    public required init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        address        <- map["address"]
        n_tx           <- map["n_tx"]
        balance        <- map["balance"]
    }
    
    public static func == (lhs: NeoGetBalanceResponse, rhs: NeoGetBalanceResponse) -> Bool {
        return lhs.address == rhs.address
    }
}
