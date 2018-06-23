//
//  Neo.swift
//  NRLWalletSDK
//
//  Created by David Bala on 17/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import Neoutils

class NRLNeo : NRLCoin{
    var account: NeoAccount?
    
    init(mnemonic: [String], passphrase: String, fTest: Bool) {
        var network: NRLNetwork = .main(.ethereum)
        if (fTest) {
            network = .test(.ethereum)
        }
        
        let cointype = network.coinType
        
        super.init(mnemonic: mnemonic,
                   passphrase: passphrase,
                   network: network,
                   coinType: cointype,
                   seedKey: "Nist256p1 seed",
                   curve: "ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551")
    }
    
    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        var error: NSError?
        let wallet = NeoutilsGenerateFromPrivateKey(privateKey.toHexString(), &error)
        let publickey = wallet?.publicKey()
//        print("public key generated: \(publickey?.toHexString() ?? "")")
        return publickey!
    }
    
    //in neo should use secp256r1. (it was secp256k1 in ethereum)
    override func generateAddress() {
        var error: NSError?
        let wallet = NeoutilsGenerateFromPrivateKey(self.pathPrivateKey?.raw.toHexString(), &error)
        self.wif = (wallet?.wif())!
        self.address = (wallet?.address())!
    }
    
    override func createOwnWallet(created: Date, fnew: Bool) -> Bool {
        guard let privkey = self.pathPrivateKey else {
            DDLogDebug("createOwnWallet error: no pathPrivateKey")
            return false
        }
        self.account = NeoAccount(privateKey: privkey.raw.toHexString())
        return true
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {
        guard let neoAccount = self.account else {
            DDLogDebug("getWalletBalance error: no account")
            callback(NRLWalletSDKError.requestError(.invalidParameters("no account")), "")
            return
        }
        
        neoAccount.getBalance() { (asset, error) in
            if (error == nil) {
                DDLogDebug("getWalletBalance: \(String(describing: asset))")
                callback(NRLWalletSDKError.nrlSuccess, asset!)
            }
            else {
                DDLogDebug("getWalletBalance error: \(String(describing: error))")
                callback(NRLWalletSDKError.responseError(.unexpected(error!)), "")
            }
        }
    }
    
    override func getAddressesOfWallet() -> NSArray? {return nil}
    override func getPrivKeysOfWallet() -> NSArray? {return nil}
    override func getPubKeysOfWallet() -> NSArray? {return nil}
    override func getReceiveAddress() -> String? {return ""}
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {}
    //transaction
    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
}

