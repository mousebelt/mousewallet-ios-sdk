//
//  StellarNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 15/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ObjectMapper

class StellarAccountFlagsResponse: Mappable {
    
    /// Requires the issuing account to give other accounts permission before they can hold the issuing account’s credit.
    var authRequired:Bool?
    
    /// Allows the issuing account to revoke its credit held by other accounts.
    var authRevocable:Bool?
    
    /// If this is set then none of the authorization flags can be set and the account can never be deleted.
    var authImmutable:Bool?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        authRequired           <- map["auth_required"]
        authRevocable          <- map["auth_revocable"]
        authImmutable          <- map["auth_immutable"]
    }
}

class StellarAccountBalanceResponse: Mappable {
    
    /// Balance for the specified asset.
    var balance:String?
    
    /// Maximum number of asset amount this account can hold.
    var limit:String?
    
    /// The asset type. Possible values: native, credit_alphanum4, credit_alphanum12
    /// See also Constants.AssetType
    var assetType:String?
    
    /// The asset code e.g., USD or BTC.
    var assetCode:String?
    
    /// The account id of the account that created the asset.
    var assetIssuer:String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        balance           <- map["balance"]
        limit             <- map["limit"]
        assetType         <- map["asset_type"]
        assetCode         <- map["asset_code"]
        assetIssuer       <- map["asset_issuer"]
    }
}

class StellarAccountThresholdsResponse: Mappable {
    
    /// The account's threshhold for low security operations.
    var lowThreshold:Int?
    
    /// The account's threshhold for medium security operations.
    var medThreshold:Int?
    
    /// The account's threshhold for high security operations.
    var highThreshold:Int?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        lowThreshold          <- map["low_threshold"]
        medThreshold          <- map["med_threshold"]
        highThreshold         <- map["high_threshold"]
    }
}

class StellarAccountSignerResponse: Mappable {
    
    /// Public key of the signer / account id.
    var publicKey:String?
    
    /// The signature weight of the public key of the signer.
    var weight:Int?
    
    /// Not sure about this key.
    var key:String?
    
    /// Type of the key e.g. ed25519_public_key
    var type:String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        publicKey         <- map["public_key"]
        weight            <- map["weight"]
        key               <- map["key"]
        type              <- map["type"]
    }
}

///  Represents an account response, containing information relating to a single account.
///  Reffer nrlxplore stellar api "/api/v1/account/:accountId" at "https://github.com/gedanziger/nrlxplore-vcoins/wiki/Stellar#get-account-information-by-accountid")
class StellarAccountResponse: Mappable {
    
    /// The number of account subentries.
    var subentryCount:UInt?
    
    /// Flags used by the issuers of assets.
    var flags:StellarAccountFlagsResponse?
    
    /// An array of the native asset or credits this account holds.
    var balances:[StellarAccountBalanceResponse]?

    /// An object of account flags.
    var thresholds:StellarAccountThresholdsResponse?

    /// An array of account signers with their weights.
    var signers:[StellarAccountSignerResponse]?

    /// The current sequence number that can be used when submitting a transaction from this account.
    var sequence: String?

    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        subentryCount           <- map["subentry_count"]
        flags                   <- map["flags"]
        balances                <- map["balances"]
        thresholds              <- map["thresholds"]
        signers                 <- map["signers"]
        sequence                <- map["sequence"]
    }
}

class StellarTransactionAccount: TransactionAccount {
    /// Returns keypair associated with this Account.
    var keyPair: StellarKeyPair
    
    /// Returns current sequence number of this Account.
    var sequenceNumber : UInt64
    
    init(keypair: StellarKeyPair, seqnum: UInt64) {
        self.keyPair = keypair
        self.sequenceNumber = seqnum
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




