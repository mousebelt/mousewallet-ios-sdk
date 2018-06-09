//
//  BitcoinNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 29/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import NRLWalletSDK.Private
import BigInt


public class BitcoinPeer {
    let isTest: Bool
    let parameters: WSParameters

    let walletPath: String
    let dbPath: String
    
    var downloader: WSBlockChainDownloader?
    var peerGroup: WSPeerGroup?
    var wallet: WSHDWallet?

    var syncTimer = Timer()
    
    init(fTest: Bool) {
        self.isTest = fTest
        
        if (self.isTest) {
            self.parameters = WSParametersForNetworkType(WSNetworkTypeTestnet3)
        }
        else {
            self.parameters = WSParametersForNetworkType(WSNetworkTypeMain)
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.walletPath = documentsDirectory.appendingPathComponent("nrlbtc.wallet").path
        self.dbPath = documentsDirectory.appendingPathComponent("nrlbtcChainData.sql").path
        
        setNotifications()
    }
    
    func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: String) -> ()) {
        self.wallet?.recalculateSpendsAndBalance()
        let balance = String(format: "%.8f", Double((self.wallet?.balance())!) / 100000000)
        
        DDLogDebug("Balance: \(balance)")

        callback(NRLWalletSDKError.nrlSuccess, balance)
    }
    
    func getAddressesOfWallet() -> NSMutableArray {
        let allReceiveAddresses = self.wallet?.allReceiveAddresses()
        
        let addressArray = NSMutableArray()
        for address in allReceiveAddresses! {
            let encodedAddress = address as! WSAddress
            
            addressArray.add(encodedAddress.encoded() as Any)
        }

        DDLogDebug("allReceiveAddresses: \(String(describing: addressArray))")
        return addressArray
    }
    
    
    func getPrivKeysOfWallet() -> NSMutableArray {
        let allReceiveAddresses = self.wallet?.allReceiveAddresses()
        
        let privkeys = NSMutableArray()
        for address in allReceiveAddresses! {
            let encodedAddress = address as! WSAddress
            let privkey = self.wallet?.privateKey(for: encodedAddress)
            let wif = privkey?.wif(with: self.parameters)
            privkeys.add(wif as Any)
        }

        DDLogDebug("privkeys: \(privkeys)")
        return privkeys
    }
    
    func getPubKeysOfWallet() -> NSMutableArray {
        let allReceiveAddresses = self.wallet?.allReceiveAddresses()
        
        let pubkeys = NSMutableArray()
        for address in allReceiveAddresses! {
            let encodedAddress = address as! WSAddress
            let pubkey = self.wallet?.publicKey(for: encodedAddress)
            pubkeys.add(pubkey as Any)
        }
        
        DDLogDebug("pubkeys: \(pubkeys)")
        return pubkeys
    }
    
    func getReceiveAddress() -> String {
        let address = self.wallet?.receiveAddress()
        DDLogDebug("receiveAddress: \(String(describing: address))")
        
        return (address?.encoded())!
    }
    
    func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()){
        let transactions = self.wallet?.transactions(in: NSRange(location: offset, length: count))
        DDLogDebug("allTransactions: \(String(describing: transactions))")
        
        callback(NRLWalletSDKError.nrlSuccess, transactions!)
    }
    
    func createWallet(seedData: Data, created: Date, fnew: Bool) {
        if (!fnew) {
            self.wallet = WSHDWallet.load(fromPath: self.walletPath, parameters: self.parameters, seed: seedData, created: created)
        }
        else {
            let fileManager = FileManager.default
            
            do {
                if (fileManager.fileExists(atPath: self.walletPath)) {
                    try fileManager.removeItem(atPath: self.walletPath)
                }
                if (fileManager.fileExists(atPath: self.dbPath)) {
                    try fileManager.removeItem(atPath: self.dbPath)
                }
            }
            catch let error as NSError {
                print("File remove failed: \(error)")
            }
        }
        
        if (!(self.wallet != nil)) {
            self.wallet = WSHDWallet(parameters: self.parameters, seeddata: seedData)
            self.wallet?.save(toPath: self.walletPath)
        }
    }
    
    func createPeerGroup() {
        let store = WSMemoryBlockStore(parameters: self.parameters) as WSBlockStore
        self.downloader = WSBlockChainDownloader(store: store, wallet: self.wallet)
        do {
            self.downloader?.coreDataManager = try WSCoreDataManager(path: self.dbPath)
        } catch {
            print(error)
        }
        
        self.peerGroup = WSPeerGroup(parameters: self.parameters)
        self.peerGroup?.maxConnections = 10;

    }
    
    func startSyncSchedular() {
        self.syncTimer.invalidate()
        self.syncTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(trySync(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func trySync(_ timer:Timer) {
        if (!(self.peerGroup?.isDownloading())!) {
            if (self.peerGroup?.startDownload(with: self.downloader))! {
                DDLogVerbose("start syncing")
            }
        }
    }
    
    func connect() -> Bool {
        if (!(self.peerGroup?.isStarted())!) {
            if (self.peerGroup?.startConnections())! {
                startSyncSchedular()
                DDLogVerbose("peers connected and start syncing")
                return true
            }
            return false
        }
        
        return true
    }
    
    func disconnect() -> Bool {
        if ((self.peerGroup?.isStarted())!) {
            if (self.peerGroup?.stopConnections())! {
                self.syncTimer.invalidate()
                if (stopSync()) {
                    DDLogVerbose("peers disconnected")
                    return true
                }
            }
            return false
        }
        
        if (stopSync()) {
            DDLogVerbose("peers disconnected")
            return true
        }

        return false
    }
    
    func startSync() -> Bool {
        if (!(self.peerGroup?.isDownloading())!) {
            if (self.peerGroup?.startDownload(with: self.downloader))! {
                DDLogVerbose("start syncing")
                return true
            }
            return false
        }
        return true
    }
    
    func stopSync() -> Bool {
        if ((self.peerGroup?.isDownloading())!) {
            self.peerGroup?.stopDownload()
            DDLogVerbose("stop syncing")
            return true
        }
        return true
    }
    
    func isConnected() -> Bool {
        return (self.peerGroup?.isStarted())!
    }
    
    func isDownloading() -> Bool {
        return (self.peerGroup?.isDownloading())!
    }
    
    //transaction
    func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let address = WSAddress(parameters: self.parameters, encoded: to)
        
        do {
            let builder = try self.wallet?.buildTransaction(to: address, forValue: value, fee: fee)
            let tx = try self.wallet?.signedTransaction(with: builder)
            
            if (!(self.peerGroup?.publishTransaction(tx))!) {
                DDLogInfo("Publish failed, no connected peers");
                callback(NRLWalletSDKError.syncError(.failedToConnect), 0)
                return
            }
            
            DDLogVerbose("\(value) was sent to \(to)")
            let hash: WSHash256 = (tx?.txId())!
            callback(NRLWalletSDKError.nrlSuccess, hash.data() as Any)
        } catch {
            DDLogDebug("sendTransaction error: \(error)")
            callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
    
    func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let address = WSAddress(parameters: self.parameters, encoded: to)
        
        do {
            let builder = try self.wallet?.buildTransaction(to: address, forValue: value, fee: fee)
            let tx: WSSignedTransaction = (try self.wallet?.signedTransaction(with: builder))!
            
            DDLogVerbose("signed transaction (\(value) to \(to))")
            callback(NRLWalletSDKError.nrlSuccess, tx as Any)
        } catch {
            print(error)
            callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
    
    func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let txSigned = tx as! WSSignedTransaction
        if (!(self.peerGroup?.publishTransaction(txSigned))!) {
            DDLogInfo("Publish failed, no connected peers");
            callback(NRLWalletSDKError.syncError(.failedToConnect), 0)
        }

        let hash: WSHash256 = (txSigned.txId())!
        callback(NRLWalletSDKError.nrlSuccess, hash.data() as Any)
    }
    
    
    // Notification
    func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(WalletDidRegisterTransaction(notification:)), name: NSNotification.Name.WSWalletDidRegisterTransaction, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WalletDidUpdateTransactionsMetadata(notification:)), name: NSNotification.Name.WSWalletDidUpdateTransactionsMetadata, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidFinishDownload(notification:)), name: NSNotification.Name.WSPeerGroupDidFinishDownload, object: nil)

    }
    
    //callback from BitcoinNetwork
    @objc func WalletDidRegisterTransaction(notification: Notification) {
        self.wallet?.save(toPath: self.walletPath)
        
        let tx = notification.userInfo![WSWalletTransactionKey] as! WSSignedTransaction
        DDLogDebug("Registered transaction: \(tx)")
    }
    

    
    @objc func WalletDidUpdateTransactionsMetadata(notification: Notification) {
        let metadataById = notification.userInfo![WSWalletTransactionsMetadataKey] as! NSDictionary
        DDLogDebug("Mined transactions: \(metadataById)")
    }
    
    @objc func PeerGroupDidFinishDownload(notification: Notification) {
        if (stopSync()) {
            DDLogVerbose("Fully synced and stop sync")
        }
    }
}
