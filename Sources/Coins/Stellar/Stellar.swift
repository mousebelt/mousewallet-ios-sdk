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
    var accountCreator: StellarAccountCreator
    var trNetwork: Network
    
    init(mnemonic: [String], passphrase: String, fTest: Bool) {
        var network: NRLNetwork = .main(.stellar)
        self.trNetwork = Network.public
        if (fTest) {
            network = .test(.ethereum)
            self.trNetwork = Network.testnet
        }
        
        let cointype = network.coinType
        
        self.accountCreator = StellarAccountCreator()
        
        super.init(mnemonic: mnemonic,
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
    
    override func getPublicKey() -> Data {
        return self.pubkeyData!
    }
    
    override func createOwnWallet(created: Date, fnew: Bool) -> Bool {
        let bindedString = self.mnemonic.joined(separator: " ")

        do {
            self.keyPair = try StellarWallet.createKeyPair(mnemonic: bindedString, passphrase: "Test", index: 0)
            DDLogDebug("Wallet creted. \(String(describing: self.keyPair?.accountId))")
//            try generateExternalKeyPair(at: 0)
        } catch {
            DDLogDebug("Create stellar wallet error: \(error)")
            return false
        }
        
        guard let creatorKeys = self.accountCreator.creatorKeyPair else {
            DDLogDebug("Acount Creator has no keypair")
            return false
        }
        
        let creatorAddress = creatorKeys.accountId
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: creatorAddress))"
        guard let destKyes = self.keyPair else {
            DDLogDebug("createOwnWallet keypair error")
            return false
        }

        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.then { res in
                return Promise<VCoinResponse> { seal in
                    DDLogDebug("account info \(String(describing: res.data))")
                    let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data)
                    guard var sqnum: UInt64 = UInt64((resObj?.sequence)!) else {
                        DDLogDebug("Acount Creator failed. Not sequence num from account.")
                        return
                    }

                    DDLogDebug("seqnum = \(sqnum)")
                    DDLogDebug("New account: \(destKyes.accountId)")
                    //testnet seq number of creator
                    
                    let sourceTransactionAccount = StellarTransactionAccount(keypair: creatorKeys, seqnum: sqnum)
                    
                    // build a create account operation.
                    let createAccountOperation = CreateAccountOperation(destination: destKyes, startBalance: 2.0)

                    // build a transaction that contains the create account operation.
                    let transaction = try StellarTransaction(sourceAccount: sourceTransactionAccount,
                                                     operations: [createAccountOperation],
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
                let resObj3 = Mapper<ETHSendSignedTransactionResponse>().map(JSONObject: res3.data)
            }.catch { error in
                DDLogDebug("Create stellar wallet request error: \(error)")
        }
    
        return true
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {}
    override func getAddressesOfWallet() -> NSArray? {return nil}
    override func getPrivKeysOfWallet() -> NSArray? {return nil}
    override func getPubKeysOfWallet() -> NSArray? {return nil}
    override func getReceiveAddress() -> String? {return ""}
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        guard let creatorKeys = self.accountCreator.creatorKeyPair else {
            DDLogDebug("Acount Creator has no keypair")
            return
        }
        
        let account: String = creatorKeys.accountId

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
    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        guard let creatorKeys = self.accountCreator.creatorKeyPair else {
            DDLogDebug("Acount Creator has no keypair")
            callback(NRLWalletSDKError.transactionError(.transactionFailed("Acount Creator has no keypair" as! Error)), 0)
            return
        }
        
        let creatorAddress = creatorKeys.accountId
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: creatorAddress))"
        guard let destKyes = self.keyPair else {
            DDLogDebug("createOwnWallet keypair error")
            callback(NRLWalletSDKError.transactionError(.transactionFailed("createOwnWallet keypair error" as! Error)), 0)
            return
        }
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.then { res in
                return Promise<VCoinResponse> { seal in
                    DDLogDebug("account info \(String(describing: res.data))")
                    let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data)
                    guard var sqnum: UInt64 = UInt64((resObj?.sequence)!) else {
                        DDLogDebug("Acount Creator failed. Not sequence num from account.")
                        return
                    }
                    
                    DDLogDebug("seqnum = \(sqnum)")
                    sqnum = 79194227661078528;
                    DDLogDebug("seqnum = \(sqnum)")
                    //testnet seq number of creator
                    //                    let seq: UInt64 = 41275142520700928;
                    
                    let sourceTransactionAccount = StellarTransactionAccount(keypair: creatorKeys, seqnum: sqnum)
                    
                    // build a create account operation.
                    let createAccountOperation = CreateAccountOperation(destination: destKyes, startBalance: 1.0)
                    
                    // build a transaction that contains the create account operation.
                    let transaction = try StellarTransaction(sourceAccount: sourceTransactionAccount,
                                                             operations: [createAccountOperation],
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
                let resObj3 = Mapper<ETHSendSignedTransactionResponse>().map(JSONObject: res3.data)
            }.catch { error in
                DDLogDebug("Create stellar wallet request error: \(error)")
        }
    }
    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}

}
