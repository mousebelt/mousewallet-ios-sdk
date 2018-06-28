//
//  AccountEntryXDR.swift
//  stellarsdk
//
//  Created by Rogobete Christian on 12.02.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct AccountEntryXDR: XDRCodable {
    let accountID: StellarPublicKey
    public let balance: Int64
    public let sequenceNumber: UInt64
    public let numSubEntries:UInt32
    public var inflationDest: StellarPublicKey?
    public let flags:UInt32
    public let homeDomain:String?
    public let thresholds:WrappedData4
    public let signers: [SignerXDR]
    public let reserved: Int32 = 0
    

    public init(accountID: StellarPublicKey, balance:Int64, sequenceNumber:UInt64, numSubEntries:UInt32, inflationDest:StellarPublicKey? = nil, flags:UInt32, homeDomain:String? = nil, thresholds: WrappedData4, signers: [SignerXDR]) {
        self.accountID = accountID
        self.balance = balance
        self.sequenceNumber = sequenceNumber
        self.numSubEntries = numSubEntries
        self.inflationDest = inflationDest
        self.flags = flags
        self.homeDomain = homeDomain
        self.thresholds = thresholds
        self.signers = signers
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        accountID = try container.decode(StellarPublicKey.self)
        balance = try container.decode(Int64.self)
        sequenceNumber = try container.decode(UInt64.self)
        numSubEntries = try container.decode(UInt32.self)
        inflationDest = try decodeArray(type: StellarPublicKey.self, dec: decoder).first
        flags = try container.decode(UInt32.self)
        homeDomain = try container.decode(String.self)
        thresholds = try container.decode(WrappedData4.self)
        signers = try decodeArray(type: SignerXDR.self, dec: decoder)
        _ = try container.decode(Int32.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(accountID)
        try container.encode(balance)
        try container.encode(sequenceNumber)
        try container.encode(numSubEntries)
        try container.encode(inflationDest)
        try container.encode(flags)
        try container.encode(thresholds)
        try container.encode(signers)
        try container.encode(reserved)
    }
}
