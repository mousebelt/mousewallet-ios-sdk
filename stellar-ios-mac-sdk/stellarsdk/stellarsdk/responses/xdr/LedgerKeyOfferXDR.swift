//
//  LedgerKeyOfferXDR.swift
//  stellarsdk
//
//  Created by Rogobete Christian on 13.02.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct LedgerKeyOfferXDR: XDRCodable {
    let sellerId: StellarPublicKey
    let offerId: UInt64
    
    init(sellerId: StellarPublicKey, offerId: UInt64) {
        self.sellerId = sellerId
        self.offerId = offerId
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(sellerId)
        try container.encode(offerId)
    }
}
