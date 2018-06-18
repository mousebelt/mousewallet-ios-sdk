//
//  StellarAccountCreator.swift
//  NRLWalletSDK
//
//  Created by David Bala on 15/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation


/*
 Now that you have a seed and public key, you can create an account. In order to prevent people from making a huge number of unnecessary accounts, each account must have a minimum balance of 1 lumen (lumens are the built-in currency of the Stellar network).[2] Since you don’t yet have any lumens, though, you can’t pay for an account. In the real world, you’ll usually pay an exchange that sells lumens in order to create a new account.[3]
 
 StellarAccountCreator is for AccountCreation operation for new accounts. This will have enough lumens and provide operations to create accounts.
 */

class StellarAccountCreator {
    var creatorKeyPair: StellarKeyPair?
    
    init () {
        do {
            //this seed data should be loaded from encrypted file. Or from mnemonic which is saved in local file or sqlite.
//            let mnemonic = "casino roast sign inflict blouse clown office fame slot reward traffic penalty"
//            self.creatorKeyPair = try StellarWallet.createKeyPair(mnemonic: mnemonic, passphrase: "Test", index: 0)
            self.creatorKeyPair = try StellarKeyPair(secretSeed: "SAFGCNACP7QSEJTB24JPVGEVXU7ZGEBQUCRVPO4PTTOR45XDBSSPHYTT")
        } catch {
            DDLogDebug("Stellar Account Creator init error: \(error)")
        }
    }
}
