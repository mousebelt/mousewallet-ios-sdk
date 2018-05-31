//
//  BitcoinNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 29/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import NRLWalletSDK.Private


protocol PeearEventCallback {
    func walletDidRegisterTransaction(notification: Notification)
    func peerGroupDidStartDownload(notification: Notification)
    func peerGroupDidFinishDownload(notification: Notification)
}


public class BitcoinPeer {
    let isTest: Bool
    let parameters: WSParameters

    let walletPath: String
    let dbPath: String
    var listener: PeearEventCallback
    
    var downloader: WSBlockChainDownloader?
    var peerGroup: WSPeerGroup?
    var wallet: WSHDWallet?
    
    init(listener: PeearEventCallback, fTest: Bool) {
        self.isTest = fTest
        self.listener = listener
        
        if (self.isTest) {
            self.parameters = WSParametersForNetworkType(WSNetworkTypeTestnet3)
        }
        else {
            self.parameters = WSParametersForNetworkType(WSNetworkTypeMain)
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.walletPath = documentsDirectory.appendingPathComponent("nrlbtc.wallet").path
        self.dbPath = documentsDirectory.appendingPathComponent("nrlbtc.sql").path
        
//        createWallet(seedData: seedData)
//        createPeerGroup()
        
//        showWalletStatus()
    }
    
    func showWalletStatus() {
        let balance = self.wallet?.balance()
        print("Balance: \(String(describing: balance))")
        
        let allReceiveAddresses = self.wallet?.allReceiveAddresses()
        print("allReceiveAddresses: \(String(describing: allReceiveAddresses))")
        
        let privkeys = NSMutableArray()
        let pubkeys = NSMutableArray()
        for address in allReceiveAddresses! {
            let encodedAddress = address as! WSAddress
            let privkey = self.wallet?.privateKey(for: encodedAddress)
            let pubkey = self.wallet?.publicKey(for: encodedAddress)
            let wif = privkey?.wif(with: self.parameters)
            privkeys.add(wif as Any)
            pubkeys.add(pubkey as Any)
        }
        
        print("privkeys: \(privkeys)")
        print("pubkeys: \(pubkeys)")
        
        let address = self.wallet?.receiveAddress()
        print("receiveAddress: \(String(describing: address))")
        
        let transactions = self.wallet?.allTransactions()
        print("allTransactions: \(String(describing: transactions))")
    }
    
    func createWallet(seedData: Data) {
        self.wallet = WSHDWallet.init(parameters: self.parameters, seeddata: seedData)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WalletDidRegisterTransaction(notification:)), name: NSNotification.Name.WSWalletDidRegisterTransaction, object: nil)
        
        showWalletStatus()
    }
    
    func createPeerGroup() {
        let store = WSMemoryBlockStore.init(parameters: self.parameters)
        self.downloader = WSBlockChainDownloader.init(store: store, wallet: self.wallet)
        
        self.peerGroup = WSPeerGroup.init(parameters: self.parameters)
        self.peerGroup?.maxConnections = 10;
        
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidStartDownload(notification:)), name: NSNotification.Name.WSPeerGroupDidStartDownload, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidFinishDownload(notification:)), name: NSNotification.Name.WSPeerGroupDidFinishDownload, object: nil)
    }
    
    func connect() {
        if (!(self.peerGroup?.isStarted())!) {
            if (self.peerGroup?.startConnections())! {
                print("peers connected")
            }
        }
    }
    
    func disconnect() {
        if ((self.peerGroup?.isStarted())!) {
            if (self.peerGroup?.stopConnections())! {
                print("peers disconnected")
            }
        }
    }
    
    func startSync() {
        if (!(self.peerGroup?.isDownloading())!) {
            if (self.peerGroup?.startDownload(with: self.downloader))! {
                print("start syncing")
            }
        }
    }
    
    func stopSync() {
        if ((self.peerGroup?.isDownloading())!) {
            self.peerGroup?.stopDownload()
            print("stop syncing")
        }
    }
    
    //callback from BitcoinNetwork
    @objc func WalletDidRegisterTransaction(notification: Notification) {
        self.listener.walletDidRegisterTransaction(notification: notification)
    }
    
    @objc func PeerGroupDidStartDownload(notification: Notification) {
        self.listener.peerGroupDidStartDownload(notification: notification)
    }
    
    @objc func PeerGroupDidFinishDownload(notification: Notification) {
        self.listener.peerGroupDidFinishDownload(notification: notification)
    }

}
