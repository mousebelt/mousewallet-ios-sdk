//
//  Account.swift
//  stellarsdk
//
//  Created by Rogobete Christian on 13.02.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

/// Represents an account in Stellar network with it's sequence number.
public class Account: TransactionAccount
{
    public private (set) var keyPair: StellarKeyPair
    public private (set) var sequenceNumber: UInt64
    
    /// Creates a new Account object.
    ///
    /// - Parameter keyPair: StellarKeyPair associated with this Account.
    /// - Parameter sequenceNumber: Current sequence number of the account (can be obtained using the sdk or horizon server).
    ///
    public init(keyPair: StellarKeyPair, sequenceNumber: UInt64) {
        self.keyPair = keyPair
        self.sequenceNumber = sequenceNumber
    }
    
    ///  Returns sequence number incremented by one, but does not increment internal counter.
    public func incrementedSequenceNumber() -> UInt64 {
        return sequenceNumber + 1
    }
    
    /// Increments sequence number in this object by one.
    public func incrementSequenceNumber() {
        sequenceNumber += 1
    }
}
