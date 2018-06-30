//
//  Neo.swift
//  NRLWalletSDK
//
//  Created by David Bala on 17/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import Neoutils
import Alamofire
import ObjectMapper
import PromiseKit

class NRLNeo : NRLCoin{
    var account: NeoAccount?
    
    init(symbol: String, mnemonic: [String], passphrase: String, fTest: Bool) {
        var network: NRLNetwork = .main(.ethereum)
        if (fTest) {
            network = .test(.ethereum)
        }
        
        let cointype = network.coinType
        
        super.init(symbol: symbol,
                   mnemonic: mnemonic,
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
        do {
            try generateExternalKeyPair(at: 0)
            
            guard let privkey = self.pathPrivateKey else {
                DDLogDebug("createOwnWallet error: no pathPrivateKey")
                return false
            }
            self.account = NeoAccount(privateKey: privkey.raw.toHexString())
            guard let neoAccount = self.account else {
                DDLogDebug("Failed to create account")
                return false
            }
            
            DDLogDebug("wif: \(neoAccount.privateKeyString)")
            DDLogDebug("pubkeuy: \(neoAccount.publicKeyString)")
            DDLogDebug("address: \(neoAccount.address)")
             return true
        } catch {
            DDLogDebug(error as! String)
            return false
        }
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
    
    override func getAddressesOfWallet() -> NSArray? {
        guard let neoAccount = self.account else {
            DDLogDebug("no account")
            return nil
        }
        
        return NSArray(array: [neoAccount.address])
    }
    override func getPrivKeysOfWallet() -> NSArray? {
        guard let neoAccount = self.account else {
            DDLogDebug("no account")
            return nil
        }
        
        return NSArray(array: [neoAccount.privateKeyString])
    }
    override func getPubKeysOfWallet() -> NSArray? {
        guard let neoAccount = self.account else {
            DDLogDebug("no account")
            return nil
        }
        
        return NSArray(array: [neoAccount.publicKeyString])
    }
    override func getReceiveAddress() -> String {
        guard let neoAccount = self.account else {
            DDLogDebug("no account")
            return ""
        }
        
        return neoAccount.address
    }
    
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        guard let neoAccount = self.account else {
            DDLogDebug("Failed to create account")
            callback(NRLWalletSDKError.transactionError(.transactionFailed("no account" as! Error)), 0)
            return
        }
        
        let address = neoAccount.address
        let url = "\(urlNeoServer)/api/v1/address/txs/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url, parameters: ["offset": offset, "count": count, "order": order])
            }.done { res in
                DDLogDebug("Transactions: \(String(describing: res.data))")
                let resObj = Mapper<NeoTransactionsMap>().map(JSONObject: res.data)
                
                callback(NRLWalletSDKError.nrlSuccess, resObj as Any)
            }.catch { error in
                callback((error as? NRLWalletSDKError)!, 0)
        }
    }
    //transaction
    
    override func sendTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.account?.sendAssetTransaction(asset: asset, amount: value, toAddress: to) { (val, error) in
            if ((error) != nil) {
                callback(NRLWalletSDKError.nrlSuccess, val as Any)
            }
            else {
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error!)), 0)
            }
        }
    }
    override func signTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.account?.signAssetTransaction(asset: asset, amount: value, toAddress: to) { (error, val) in
            if ((error) != nil) {
                callback(NRLWalletSDKError.nrlSuccess, val as Any)
            }
            else {
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error!)), 0)
            }
        }
    }
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.account?.sendSignedAssetTransaction(payload: tx as! String) { (val, error) in
            if ((error) != nil) {
                callback(NRLWalletSDKError.nrlSuccess, val as Any)
            }
            else {
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error!)), 0)
            }
        }
    }
}

