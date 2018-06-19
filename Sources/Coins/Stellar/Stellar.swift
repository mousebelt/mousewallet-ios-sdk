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
    
    init(mnemonic: [String], seed: Data, fTest: Bool) {
        var network: NRLNetwork = .main(.stellar)
        if (fTest) {
            network = .test(.ethereum)
        }
        
        let cointype = network.coinType
        
        self.accountCreator = StellarAccountCreator()
        
        super.init(mnemonic: mnemonic,
                   seed: seed,
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

        self.masterPrivateKey = NRLPrivateKey(seed: self.seed, privkey: generateMasterKey(), coin: self)
        self.pathPrivateKey = try path_derive(index: index)
        
        let stellarSeed = try! StellarSeed(bytes: (self.pathPrivateKey?.raw.bytes)!)
        generatePublickey(seed: stellarSeed)
    }
    
    override func generateInternalKeyPair(at index: UInt32) throws {
        try generateExternalKeyPair(at: index)
    }
    
    // m/44'/coin_type'/0'/external
    private func path_derive(index: UInt32) throws -> NRLPrivateKey {
        return masterPrivateKey!
            .derived_Ed25519(at: 44)
            .derived_Ed25519(at: coinType)
            .derived_Ed25519(at: index)
    }
    
    override func getPublicKey() -> Data {
        return self.pubkeyData!
    }
    
    override func createOwnWallet(created: Date, fnew: Bool) {
        let bindedString = self.mnemonic.joined(separator: " ")
        
        do {
            self.keyPair = try StellarWallet.createKeyPair(mnemonic: bindedString, passphrase: "Test", index: 0)
//            try generateExternalKeyPair(at: 0)
        } catch {
            DDLogDebug("Create stellar wallet error: \(error)")
            return
        }
        
        guard let creatorKeys = self.accountCreator.creatorKeyPair else {
            DDLogDebug("Acount Creator has no keypair")
            return
        }
        
        let creatorAddress = creatorKeys.accountId
        let url = "\(urlStellarServer)/api/v1/account/\(String(describing: creatorAddress))"
        guard let destKyes = self.keyPair else {
            DDLogDebug("createOwnWallet keypair error")
            return
        }
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.then { res in
                return Promise<VCoinResponse> { seal in
                    DDLogDebug("account info \(res)")
                    let resObj = Mapper<StellarAccountResponse>().map(JSONObject: res.data)
                    let sourceTransactionAccount = StellarTransactionAccount(keypair: creatorKeys, seqnum: (resObj?.sequenceNumber)!)
                    
                    // build a create account operation.
                    let createAccountOperation = CreateAccountOperation(destination: destKyes, startBalance: 2.0)

                    // build a transaction that contains the create account operation.
                    let transaction = try StellarTransaction(sourceAccount: sourceTransactionAccount,
                                                     operations: [createAccountOperation],
                                                     memo: Memo.none,
                                                     timeBounds:nil)

                    // sign the transaction.
                    try transaction.sign(keyPair: sourceTransactionAccount.keyPair, network: Network.public)
                    
                    let url2 = "\(urlStellarServer)/api/v1/transaction"
                    
                    let envelope = try transaction.encodedEnvelope()
                    if let encoded = envelope.urlEncoded {
                        guard let data = ("tx=" + encoded).data(using: .utf8) else {
                            seal.reject(NRLWalletSDKError.requestError(.invalidParameters("encoded data error")))
                            return
                        }
                    
                        firstly {
                            sendRequest(responseObject:VCoinResponse.self, url: url2, method: .post, parameters: ["tx": data])
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
                DDLogDebug("res3: \(res3)")
                let resObj3 = Mapper<ETHSendSignedTransactionResponse>().map(JSONObject: res3.data)
            }.catch { error in
                DDLogDebug("Create stellar wallet request error: \(error)")
        }
        
        // load the source account from horizon to be sure that we have the current sequence number.
//        sdk.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
//            switch response {
//            case .success(let accountResponse): // source account successfully loaded.
//                do {
//                    // build a create account operation.
//                    let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: 2.0)
//
//                    // build a transaction that contains the create account operation.
//                    et transaction = try Transaction(sourceAccount: accountResponse,
//                                                     operations: [createAccount],
//                                                     memo: Memo.none,
//                                                     timeBounds:nil)
//
//                    // sign the transaction.
//                    try transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
//
//                    // submit the transaction to the stellar network.
//                    try sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
//                        switch response {
//                        case .success(_):
//                            print("Account successfully created.")
//                        case .failure(let error):
//                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Create account", horizonRequestError: error)
//                        }
//                    }
//                } catch {
//                    // ...
//                }
//            case .failure(let error): // error loading account details
//                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
//            }
//        }

    }
    override func createPeerGroup() {}
    override func connectPeers() -> Bool {return false}
    override func disConnectPeers() -> Bool {return false}
    override func startSyncing() -> Bool {return false}
    override func stopSyncing() -> Bool {return false}
    override func isConnected() -> Bool {return false}
    override func isDownloading() -> Bool {return false}
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {}
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
