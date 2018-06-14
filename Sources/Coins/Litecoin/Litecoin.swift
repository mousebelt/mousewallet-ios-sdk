//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import BRCore

class NRLLitecoin : NRLCoin{
    let isTest: Bool;
    fileprivate var walletManager: WalletManager?
    private var walletCoordinator: WalletCoordinator?
    private var feeUpdater: FeeUpdater?
    private var reachability = ReachabilityMonitor()
    private let noAuthApiClient = BRAPIClient(authenticator: NoAuthAuthenticator())
    private var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    private var launchURL: URL?
    private var defaultsUpdater: UserDefaultsUpdater?
    private var hasPerformedWalletDependentInitialization = false
    private var didInitWallet = false
    private let pin = "1234"
    
    init(mnemonic: [String], seed: Data, fTest: Bool) {
        self.isTest = fTest;
        var network: NRLNetwork = .main(.litecoin)
        if (fTest) {
            network = .test(.litecoin)
        }
        
        let cointype = network.coinType
        
        super.init(mnemonic: mnemonic,
                   seed: seed,
                   network: network,
                   coinType: cointype,
                   seedKey: "Bitcoin seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }
    
    //from https://github.com/onmyway133/AddressGenerator
    var pubkeyhash: UInt8 {
        if (self.isTest) {
            return 0x6f //??? maybe no testnet in litecoin
        }
        return 0x30
    }
    var privatekey: UInt8 {
        if (self.isTest) {
            return 0xef//??? maybe no testnet in litecoin
        }
        return 0xb0
    }
    var scripthash: UInt8 {
        if (self.isTest) {
            return 0xc4
        }
        return 0x05
    }
    
    var magic: UInt32 {
        if (self.isTest) {
            return 0x0b110907
        }
        return 0xf9beb4d9
    }
    
    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        let publicKey = Crypto.generatePublicKey(data: privateKey, compressed: true)
        return publicKey;
    }
    
    //compressed is only for keys start with L, K
    //https://github.com/pointbiz/bitaddress.org/releases
    public func toWIF(privatekey: Data, compressed: Bool = false) -> String {
        var data = Data([self.privatekey]) + privatekey
        if (compressed) {
            data = data + Data([0x01]);
        }
        let checksum = Crypto.doubleSHA256(data).prefix(4)
        return Base58.encode(data + checksum)
    }
    
    func publicKeyHashToAddress(_ hash: Data) -> String {
        let checksum = Crypto.doubleSHA256(hash).prefix(4)
        let address = Base58.encode(hash + checksum)
        return address
    }
    
    func toAddress(publickkey: Data) -> String {
        let hash = Data([self.pubkeyhash]) + Crypto.hash160(publickkey)
        return publicKeyHashToAddress(hash)
    }
    
    override func generateAddress() {
        self.address = toAddress(publickkey: (self.pathPrivateKey?.nrlPublicKey().raw)!);
        self.wif = toWIF(privatekey: (self.pathPrivateKey?.raw)!, compressed: true);
    }
    
    private func didInitWalletManager() {
        guard let walletManager = walletManager else { assert(false, "WalletManager should exist!"); return }
        hasPerformedWalletDependentInitialization = true
        
        DDLogDebug("PinLength set \(walletManager.pinLength)")
        
        walletCoordinator = WalletCoordinator(walletManager: walletManager)
        feeUpdater = FeeUpdater(walletManager: walletManager)
        defaultsUpdater = UserDefaultsUpdater(walletManager: walletManager)
    }
    
    private func startDataFetchers() {
        feeUpdater?.refresh()
        defaultsUpdater?.refresh()
    }
    
    func clearKeychain() {
        let classes = [kSecClassGenericPassword as String,
                       kSecClassInternetPassword as String,
                       kSecClassCertificate as String,
                       kSecClassKey as String,
                       kSecClassIdentity as String]
        classes.forEach { className in
            SecItemDelete([kSecClass as String: className]  as CFDictionary)
        }
    }
    
    
    func removeWallet(pin: String = "forceWipe") -> Bool {
        return self.walletManager!.wipeWallet(pin: pin)
    }
    
    //mnemonic should be procesed by pin code. so call self.walletManager?.seedPhrase(pin: <#T##String#>)
    func getPhrase() -> String {
        let bindedString = self.mnemonic.joined(separator: " ")
        DDLogDebug("bindString is: \(bindedString)")
        
        let phraseLen = strlen(bindedString) + 1
        let phraseData = CFDataCreate(secureAllocator, bindedString, phraseLen)
        let phrase = CFStringCreateFromExternalRepresentation(secureAllocator, phraseData,
                                                              CFStringBuiltInEncodings.UTF8.rawValue) as String
        
        return phrase
    }
    
    //override functions for own wallet and synchronizing as spv
    override func createOwnWallet(created: Date, fnew: Bool) {
        self.walletManager = try? WalletManager(dbPath: nil)
        let _ = self.walletManager?.wallet //attempt to initialize wallet
        
        if (fnew) {
            if (!(self.walletManager?.noWallet)!) {
                DDLogDebug("createOwnWallet: already created")
                if (!(self.walletManager?.forceSetPin(newPin: self.pin))!) {
                    DDLogDebug("Failed to forceSetPin")
                    return
                }

                if (!self.removeWallet(pin: self.pin)) {
                    DDLogDebug("Failed to remove original wallet")
                    return
                }
            }
        }

        if (self.walletManager?.noWallet)! {
            guard self.walletManager?.setSeedPhrase(getPhrase()) != nil else {
                DDLogDebug("Failed to Publick key generation")
                return
            }
            
            DDLogDebug("Wallet created : \(Date())")
            self.walletManager = try? WalletManager(dbPath: nil)
            let _ = self.walletManager?.wallet //attempt to initialize wallet
        }
        
        DispatchQueue.main.async {
            self.didInitWallet = true
            if !self.hasPerformedWalletDependentInitialization {
                self.didInitWalletManager()
            }
        }
    }
    
    override func createPeerGroup() {
        if !self.hasPerformedWalletDependentInitialization {
            self.didInitWalletManager()
        }
    }
    
    override func connectPeers() -> Bool {
        if (self.walletManager == nil || (self.walletManager?.noWallet)!) {
            DDLogDebug("connectPeers: Failed, no wallet")
            return false
        }

        DispatchQueue.walletQueue.async {
            self.walletManager?.peerManager?.connect()
        }

        self.startDataFetchers()

        return true
    }
    
    override func disConnectPeers() -> Bool {
        DispatchQueue.walletQueue.async {
            self.walletManager?.peerManager?.disconnect()
        }
        return true
    }
    
    override func startSyncing() -> Bool {
        return false
    }
    
    override func stopSyncing() -> Bool {
        return false
    }
    
    override func isConnected() -> Bool {
        if ((self.walletManager?.peerManager == nil) || !(self.walletManager?.peerManager?.isConnected)!) {
            return false;
        }
        return true
    }
    
    override func isDownloading() -> Bool {
        return false
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: String) -> ()) {
        callback(NRLWalletSDKError.nrlSuccess, String(describing: self.walletManager?.wallet?.balance))
    }
    
    override func getAddressesOfWallet() -> NSArray {
        return self.walletManager?.wallet?.allAddresses as! NSArray
    }
    
    
    override func getPrivKeysOfWallet() -> NSArray {
        return NSArray()
    }
    
    override func getPubKeysOfWallet() -> NSArray {
        return NSArray()
    }
    
    override func getReceiveAddress() -> String {
        return (self.walletManager?.wallet?.receiveAddress)!
    }
    
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        let txs = self.walletManager?.wallet?.transactions as [BRTxRef?]?
        
        var txsReturn: [BRTransaction] = []
        
        for index in offset...offset + count {
            if (index < (txs?.count)!) {
                let brtx = txs![index]?.pointee
                txsReturn.append(brtx!)
            }
        }
        
        callback(NRLWalletSDKError.nrlSuccess, txsReturn)
    }
    
    //transaction
    
    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let tx = self.walletManager?.wallet?.createTransaction(forAmount: value, toAddress: to);
        
        guard let txSigned = tx else {
            callback(NRLWalletSDKError.cryptoError(.failedToSign), 0)
            return
        }
        
        if (!signTx(tx!)) {
            callback(NRLWalletSDKError.cryptoError(.failedToSign), 0)
            return
        }
        
        DispatchQueue.walletQueue.async {[weak self] in
            guard let myself = self else {
                callback(NRLWalletSDKError.transactionError(.publishError), 0)
                return;
            }
            
            myself.walletManager?.peerManager?.publishTx(txSigned, completion: { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
                    } else {
                        callback(NRLWalletSDKError.nrlSuccess, txSigned.pointee.txHash.description)
                    }
                }
            })
        }
    }
    
    //this is function of WalletManager+Auth.
    //This is private as walletmanager will do this function only when pin code verification is passed.
    private func signTx(_ tx: BRTxRef, forkId: Int = 0) -> Bool {
        return autoreleasepool {
            var seed = UInt512()
            defer { seed = UInt512() }
            guard let wallet = self.walletManager?.wallet else { return false }
            let phrase: String = getPhrase()
            BRBIP39DeriveKey(&seed, phrase, nil)
            return wallet.signTransaction(tx, forkId: forkId, seed: &seed)
        }
    }
    
    // forkId is 0 for bitcoin, 0x40 for b-cash
    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let tx = self.walletManager?.wallet?.createTransaction(forAmount: value, toAddress: to);
        
        if (signTx(tx!)) {
            callback(NRLWalletSDKError.nrlSuccess, tx as Any)
        }
        else {
            callback(NRLWalletSDKError.cryptoError(.failedToSign), 0)
        }
    }
    
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let txSigned = tx as! BRTxRef
        DispatchQueue.walletQueue.async {[weak self] in
            guard let myself = self else {
                callback(NRLWalletSDKError.transactionError(.publishError), 0)
                return;
            }
            
            myself.walletManager?.peerManager?.publishTx(txSigned, completion: { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
                    } else {
                        callback(NRLWalletSDKError.nrlSuccess, txSigned.pointee.txHash.description)
                    }
                }
            })
        }
    }
}

