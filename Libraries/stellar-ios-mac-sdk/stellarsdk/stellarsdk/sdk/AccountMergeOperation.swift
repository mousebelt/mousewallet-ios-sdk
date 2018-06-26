//
//  AccountMergeOperation.swift
//  stellarsdk
//
//  Created by Rogobete Christian on 16.02.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

/// Represents an account merge operation. Transfers the native balance (the amount of XLM an account holds) to another account and removes the source account from the ledger.
/// See [Stellar Guides] (https://www.stellar.org/developers/learn/concepts/list-of-operations.html#account-merge, "Account Merge Operations").
public class AccountMergeOperation:Operation {
    
    public let destination:StellarKeyPair
    
    /// Creates a new AccountMergeOperation object.
    ///
    /// - Parameter sourceAccount: Operations are executed on behalf of the source account specified in the transaction, unless there is an override defined for the operation.
    /// - Parameter destination: The account that receives the remaining XLM balance of the source account.
    ///
    public init(sourceAccount:StellarKeyPair? = nil, destination:StellarKeyPair) {
        self.destination = destination
        super.init(sourceAccount:sourceAccount)
    }
    
    /// Creates a new AccountMergeOperation object from the given StellarPublicKey object representing the destination account.
    ///
    /// - Parameter destinatioAccountPublicKey: the StellarPublicKey object representing the destination account to be used to create a new AccountMergeOperation object.
    ///
    public init(destinatioAccountPublicKey:StellarPublicKey, sourceAccount:StellarKeyPair? = nil) {
        self.destination = StellarKeyPair(publicKey: destinatioAccountPublicKey)
        super.init(sourceAccount: sourceAccount)
    }
    
    override func getOperationBodyXDR() throws -> OperationBodyXDR {
        return OperationBodyXDR.accountMerge(destination.publicKey)
    }
}
