//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ed25519C
import PromiseKit
import Alamofire
import ObjectMapper

class NRLStellar : NRLCoin{
    var pubkeyData: Data?
    var keyPair: StellarKeyPair?
    var trNetwork: Network
    var bCreated: Bool = false
    
    init(symbol: String, mnemonic: [String], passphrase: String, fTest: Bool) {
        var network: NRLNetwork = .main(.stellar)
        self.trNetwork = Network.public
        if (fTest) {
            network = .test(.ethereum)
            self.trNetwork = Network.testnet
        }
        
        let cointype = network.coinType
        
        super.init(symbol: symbol,
                   mnemonic: mnemonic,
                   passphrase: passphrase,
                   network: network,
                   coinType: cointype,
                   seedKey: "ed25519 seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }

    func accountId(bytes: [UInt8]) -> String {
        var versionByte = VersionByte.accountId.rawValue
        let versionByteData = Data(bytes: &versionByte, count: MemoryLayout.size(ofValue: versionByte))
        let payload = NSMutableData(data: versionByteData)
        payload.append(Data(bytes: bytes))
        let checksumedData = (payload as Data).crc16Data()
        
        return checksumedData.base32EncodedString
    }
    
    func secret(seed: StellarSeed) -> String {
        return seed.secret
    }
    
    func generatePublickey(seed: StellarSeed) {
        
        self.keyPair = StellarKeyPair(seed: seed)
        
        self.pubkeyData = Data(bytes: (self.keyPair?.publicKey.bytes)!)
        self.wif = secret(seed: seed);
        self.address = accountId(bytes: (self.keyPair?.publicKey.bytes)!);
        
        print("\nstellar private key = \(String(describing: self.wif))")
        print("stellar public key = \(String(describing: self.pubkeyData))")
        print("stellar address = \(String(describing: self.address))")
    }
    
    override func generateExternalKeyPair(at index: UInt32) throws {
        guard let seed  = self.seed else { return }
        guard let masterkey = generateMasterKey() else { return }

        self.masterPrivateKey = NRLPrivateKey(seed: seed, privkey: masterkey, coin: self)
        self.pathPrivateKey = try path_derive(index: index)
        
        let stellarSeed = try! StellarSeed(bytes: (self.pathPrivateKey?.raw.bytes)!)
        generatePublickey(seed: stellarSeed)
    }
    
    override func generateInternalKeyPair(at index: UInt32) throws {
        try generateExternalKeyPair(at: index)
    }
    
    // m/44'/coin_type'/0'/externalc
    private func path_derive(index: UInt32) throws -> NRLPrivateKey {
        return masterPrivateKey!
            .derived_Ed25519(at: 44)
            .derived_Ed25519(at: coinType)
            .derived_Ed25519(at: index)
    }
    
//    override func getPublicKey() -> Data {
//        return self.pubkeyData!
//    }
    
    override func createOwnWallet(created: Date, fnew: Bool) -> Bool {
        if (fnew) {
            self.bCreated = false
        }
        
        let bindedString = self.mnemonic.joined(separator: " ")

        do {
            self.keyPair = try StellarWallet.createKeyPair(mnemonic: bindedString, passphrase: "Test", index: 0)
            DDLogDebug("Wallet creted. \(String(describing: self.keyPair?.accountId))")
        } catch {
            DDLogDebug("Create stellar wallet error: \(error)")
            return false
        }

        guard let walletkey = self.keyPair else {
            DDLogDebug("Wallet key is invalid.")
            return false
        }
        
        let account = walletkey.accountId
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: account))"

        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data)
                DDLogDebug("account info: \(String(describing: resObj))")
                
                self.bCreated = true
            }.catch { error in
                DDLogDebug("Get account info request error: \(error)")
                
        }
        
        return true
    }
//                return Promise<VCoinResponse> { seal in
//                    DDLogDebug("account info \(String(describing: res.data))")
//                    let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data)
//                    guard var sqnum: UInt64 = UInt64((resObj?.sequence)!) else {
//                        DDLogDebug("Acount Creator failed. Not sequence num from account.")
//                        return
//                    }
//
//                    DDLogDebug("seqnum = \(sqnum)")
//                    DDLogDebug("New account: \(destKyes.accountId)")
//                    //testnet seq number of creator
//
//                    let sourceTransactionAccount = StellarTransactionAccount(keypair: creatorKeys, seqnum: sqnum)
//
//                    // build a create account operation.
//                    let createAccountOperation = CreateAccountOperation(destination: destKyes, startBalance: 2.0)
//
//                    // build a transaction that contains the create account operation.
//                    let transaction = try StellarTransaction(sourceAccount: sourceTransactionAccount,
//                                                     operations: [createAccountOperation],
//                                                     memo: Memo.none,
//                                                     timeBounds:nil)
//
//                    // sign the transaction.
//                    try transaction.sign(keyPair: sourceTransactionAccount.keyPair, network: self.trNetwork)
//
//                    let url2 = "\(urlStellarServer)/api/v1/transaction"
//
//                    let envelope = try transaction.encodedEnvelope()
//                    if let encoded = envelope.urlEncoded {
//
//                        DDLogDebug("Tx: \(encoded)")
//                        firstly {
//                            sendRequest(responseObject:VCoinResponse.self, url: url2, method: .post, parameters: ["tx": encoded])
//                            }.done { res2 in
//                                DDLogDebug("second response \(res2)")
//                                seal.fulfill(res2)
//                            }.catch { error2 in
//                                seal.reject(error2)
//                        }
//                    }
//                    else {
//                        seal.reject(NRLWalletSDKError.requestError(.invalidParameters("parameter encode error")))
//                    }
//                }
//            }.then { res3 in
//                return Promise<VCoinResponse> { seal in
//                    DDLogDebug("res3: \(String(describing: res3.data))")
//                    let resObj3 = Mapper<StellarSendSignedTransactionResponse>().map(JSONObject: res3.data)
//                    DDLogDebug("Create account success: hash: \(resObj3?.hash), ledger: \(resObj3?.ledger)")
//
//                    DDLogDebug("Receive back token from new account")
//                    let url = "\(urlStellarServer)/api/v1/account/\(String(describing: destKyes.accountId))"
//
//                    firstly {
//                        sendRequest(responseObject:VCoinResponse.self, url: url)
//                    }.then { res4 in
//                        DDLogDebug("account info \(String(describing: res4.data))")
//                        let resObj4 = Mapper<StellarAccountResponse>().map(JSONObject: res4.data)
//                        guard var sqnum: UInt64 = UInt64((resObj4?.sequence)!) else {
//                            DDLogDebug("Acount Creator failed. Not sequence num from account.")
//                            return
//                        }
//
//                        seal.fulfill(resObj4)
//                        }.catch { error4 in
//                            seal.reject(error4)
//                    }
//                }
//            }.then { seqDest in
//                // create the payment operation
//                let paymentOperation = PaymentOperation(sourceAccount: destKyes,
//                                                        destination: creatorKeys,
//                                                        asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
//                                                        amount: 1.5)
//
//                // create the transaction containing the payment operation
//                let transaction = try Transaction(sourceAccount: accountResponse,
//                                                  operations: [paymentOperation],
//                                                  memo: Memo.none,
//                                                  timeBounds:nil)
//
//                // sign the transaction
//                try transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
//            }.catch { error in
//                DDLogDebug("Create stellar wallet request error: \(error)")
//        }
//
//        return true
//    }
    
    override func getAddressStr() -> String? {
        guard let accountKeys = self.keyPair else {
            DDLogDebug("Acount has no keypair")
            return ""
        }
        
        return accountKeys.accountId
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {
        guard let walletkey = self.keyPair else {
            DDLogDebug("Wallet key is invalid.")
            callback(NRLWalletSDKError.accountError(.keyError), 0)
            return
        }
        
        let account = walletkey.accountId
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: account))"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                self.bCreated = true
                
                guard let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data) else {
                    DDLogDebug("Get account info respone data is null")
                    callback(NRLWalletSDKError.responseError(.unexpected("no data")), 0)
                    return
                }
                
                DDLogDebug("account info: \(String(describing: resObj))")
                
                guard let balances = resObj.balances else {
                    DDLogDebug("Account balance is nul")
                    callback(NRLWalletSDKError.responseError(.unexpected("no data")), 0)
                    return
                }
                
                let balancelist = NSMutableArray(capacity: 0)
                for balance in balances {
                    guard let balanceobj = Mapper<StellarAccountBalanceResponse>().map(JSONObject: balance) else {continue}
                    
                    balancelist.add(balanceobj)
                }
                
                callback(NRLWalletSDKError.nrlSuccess, balancelist)

            }.catch { error in
                self.bCreated = false
                DDLogDebug("Get account info request error: \(error)")
                callback(NRLWalletSDKError.responseError(.unexpected(error)), 0)
        }
    }
    
    override func getAddressesOfWallet() -> NSArray? {
        guard let walletkey = self.keyPair else {
            DDLogDebug("Wallet key is invalid.")
            return nil
        }
        
        let account = walletkey.accountId
        return NSArray(array: [account])
    }
    override func getPrivKeysOfWallet() -> NSArray? {
        guard let walletkey = self.keyPair else {
            DDLogDebug("Wallet key is invalid.")
            return nil
        }
        
        return NSArray(array: [walletkey])
    }
    
    override func getPubKeysOfWallet() -> NSArray? {
        guard let walletkey = self.keyPair else {
            DDLogDebug("Wallet key is invalid.")
            return nil
        }
        
        return NSArray(array: [walletkey.publicKey])
    }
    
    override func getReceiveAddress() -> String {
        guard let walletkey = self.keyPair else {
            DDLogDebug("Wallet key is invalid.")
            return ""
        }
        
        return walletkey.accountId
    }
    
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        guard let account = getAddressStr() else {
            DDLogDebug("Account has no address")
            callback(NRLWalletSDKError.transactionError(.transactionFailed("Account has no address" as! Error)), 0)
            return
        }

        let url = "\(urlStellarServer)/api/v1/account/txs"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url, method: .post, parameters: ["account": account])
            }.done { res in
                DDLogDebug("res: \(res)")
            }.catch { error in
                DDLogDebug("Error: \(error)")
        }
    }
    
    //transaction
    override func sendTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        guard let accountKyes = self.keyPair else {
            DDLogDebug("Account keypair error")
            callback(NRLWalletSDKError.accountError(.keyError), 0)
            return
        }
        
        guard let account = getAddressStr() else {
            DDLogDebug("Account has no address")
            callback(NRLWalletSDKError.transactionError(.transactionFailed("Account has no address" as! Error)), 0)
            return
        }
        
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: account))"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.then { res in
                return Promise<VCoinResponse> { seal in
                    self.bCreated = true
                    
                    guard let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data) else {
                        DDLogDebug("Get account info respone data is null")
                        seal.reject(NRLWalletSDKError.responseError(.unexpected("no data")))
                        return
                    }
                    
                    DDLogDebug("account info: \(String(describing: resObj))")
                    
                    guard let balances = resObj.balances else {
                        DDLogDebug("Account balance is nul")
                        seal.reject(NRLWalletSDKError.responseError(.unexpected("no data")))
                        return
                    }
                    
                    var lumens: Double = 0.0
                    for balance in balances {
                        guard let balanceobj = Mapper<StellarAccountBalanceResponse>().map(JSONObject: balance) else {continue}
                        
                        if (balanceobj.assetType == "native") {
                            lumens += Double(balanceobj.balance!)!
                        }
                    }
                    
                    if (value + fee < lumens) {
                        DDLogDebug("Balance is smaller than send value")
                        seal.reject(NRLWalletSDKError.requestError(.invalidParameters("Balance is small than send value")))
                        return
                    }
                    
                    guard let sqnum: UInt64 = UInt64((resObj.sequence)!) else {
                        DDLogDebug("Acount Creator failed. Not sequence num from account.")
                        seal.reject(NRLWalletSDKError.accountError(.seqnumError))
                        return
                    }
                    
                    let sourceTransactionAccount = StellarTransactionAccount(keypair: accountKyes, seqnum: sqnum)
                    
                    let destkeyPair = try StellarKeyPair(accountId: to)
                    
                    let paymentOperation = PaymentOperation(destination: destkeyPair,
                                                            asset: StellarAsset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                            amount: Decimal(value))
                    let transaction = try StellarTransaction(sourceAccount: sourceTransactionAccount,
                                                      operations: [paymentOperation],
                                                      memo: Memo.none,
                                                      timeBounds:nil)
                    
                    // sign the transaction.
                    try transaction.sign(keyPair: sourceTransactionAccount.keyPair, network: self.trNetwork)
                    
                    let url2 = "\(urlStellarServer)/api/v1/transaction"
                    
                    let envelope = try transaction.encodedEnvelope()
                    if let encoded = envelope.urlEncoded {
                        
                        DDLogDebug("Tx: \(encoded)")
                        firstly {
                            sendRequest(responseObject:VCoinResponse.self, url: url2, method: .post, parameters: ["tx": encoded])
                            }.done { res2 in
                                DDLogDebug("second response \(res2)")
                                seal.fulfill(res2)
                            }.catch { error2 in
                                seal.reject(error2)
                        }
                    }
                    else {
                        seal.reject(NRLWalletSDKError.requestError(.invalidParameters("parameter encode error")))
                    }
                }
            }.done { res3 in
                DDLogDebug("res3: \(String(describing: res3.data))")
                guard let resObj3 = Mapper<StellarSendSignedTransactionResponse>().map(JSONObject: res3.data) else {
                    callback(NRLWalletSDKError.transactionError(.transactionFailed("cannot get mapped data from response" as! Error)), 0)
                    return
                }
                DDLogDebug("Create account success: hash: \(String(describing: resObj3.hash)), ledger: \(String(describing: resObj3.ledger))")
                callback(NRLWalletSDKError.nrlSuccess, resObj3.hash!)
            }.catch { error in
                self.bCreated = false
                DDLogDebug("Get account info request error: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
    override func signTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        guard let accountKyes = self.keyPair else {
            DDLogDebug("Account keypair error")
            callback(NRLWalletSDKError.accountError(.keyError), 0)
            return
        }
        
        guard let account = getAddressStr() else {
            DDLogDebug("Account has no address")
            callback(NRLWalletSDKError.transactionError(.transactionFailed("Account has no address" as! Error)), 0)
            return
        }
        
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: account))"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                self.bCreated = true
                
                guard let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data) else {
                    DDLogDebug("Get account info respone data is null")
                    callback(NRLWalletSDKError.transactionError(.transactionFailed("Account no data" as! Error)), 0)
                    return
                }
                
                DDLogDebug("account info: \(String(describing: resObj))")
                
                guard let balances = resObj.balances else {
                    DDLogDebug("Account balance is nul")
                    callback(NRLWalletSDKError.transactionError(.transactionFailed("Account has no balance" as! Error)), 0)
                    return
                }
                
                var lumens: Double = 0.0
                for balance in balances {
                    guard let balanceobj = Mapper<StellarAccountBalanceResponse>().map(JSONObject: balance) else {continue}
                    
                    if (balanceobj.assetType == "native") {
                        lumens += Double(balanceobj.balance!)!
                    }
                }
                
                if (value + fee < lumens) {
                    DDLogDebug("Balance is smaller than send value")
                    callback(NRLWalletSDKError.transactionError(.transactionFailed("Balance is small than send value" as! Error)), 0)
                    return
                }
                
                guard let sqnum: UInt64 = UInt64((resObj.sequence)!) else {
                    DDLogDebug("Acount Creator failed. Not sequence num from account.")
                    
                    callback(NRLWalletSDKError.accountError(.seqnumError), 0)
                    return
                }
                
                let sourceTransactionAccount = StellarTransactionAccount(keypair: accountKyes, seqnum: sqnum)
                
                let destkeyPair = try StellarKeyPair(accountId: to)
                
                let paymentOperation = PaymentOperation(destination: destkeyPair,
                                                        asset: StellarAsset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                        amount: Decimal(value))
                let transaction = try StellarTransaction(sourceAccount: sourceTransactionAccount,
                                                         operations: [paymentOperation],
                                                         memo: Memo.none,
                                                         timeBounds:nil)
                
                // sign the transaction.
                try transaction.sign(keyPair: sourceTransactionAccount.keyPair, network: self.trNetwork)
                
                let envelope = try transaction.encodedEnvelope()
                if let encoded = envelope.urlEncoded {
                    callback(NRLWalletSDKError.nrlSuccess, encoded)
                } else {
                    callback(NRLWalletSDKError.transactionError(.transactionFailed("envelop failed" as! Error)), 0)
                }
            }.catch { error in
                self.bCreated = false
                DDLogDebug("Get account info request error: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let url2 = "\(urlStellarServer)/api/v1/transaction"
        let encoded = tx as! String;

        DDLogDebug("Tx: \(encoded)")
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url2, method: .post, parameters: ["tx": encoded])
            }.done { res in
                DDLogDebug("res3: \(String(describing: res.data))")
                guard let resObj3 = Mapper<StellarSendSignedTransactionResponse>().map(JSONObject: res.data) else {
                    callback(NRLWalletSDKError.transactionError(.transactionFailed("cannot get mapped data from response" as! Error)), 0)
                    return
                }
                DDLogDebug("Create account success: hash: \(String(describing: resObj3.hash)), ledger: \(String(describing: resObj3.ledger))")
                callback(NRLWalletSDKError.nrlSuccess, resObj3.hash)
            }.catch { error in
                self.bCreated = false
                DDLogDebug("Get account info request error: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
}
