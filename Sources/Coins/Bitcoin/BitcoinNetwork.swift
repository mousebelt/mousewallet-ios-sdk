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
    let parameters: WSParameters
    let downloader: WSBlockChainDownloader
    let peerGroup: WSPeerGroup
    let wallet: WSHDWallet
    let walletPath: String
    let dbPath: String
    let listener: PeearEventCallback
    
    init(seedData: Data, listener: PeearEventCallback) {
        self.listener = listener
        self.parameters = WSParametersForNetworkType(WSNetworkTypeMain)
        self.wallet = WSHDWallet.init(parameters: self.parameters, seeddata: seedData)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.walletPath = documentsDirectory.appendingPathComponent("nrlbtc.wallet").path
        self.dbPath = documentsDirectory.appendingPathComponent("nrlbtc.sql").path
        
        let store = WSMemoryBlockStore.init(parameters: self.parameters)
        self.downloader = WSBlockChainDownloader.init(store: store, wallet: self.wallet)
        
        self.peerGroup = WSPeerGroup.init(parameters: self.parameters)
        self.peerGroup.maxConnections = 10;
        
        NotificationCenter.default.addObserver(self, selector: #selector(WalletDidRegisterTransaction(notification:)), name: NSNotification.Name.WSWalletDidRegisterTransaction, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidStartDownload(notification:)), name: NSNotification.Name.WSPeerGroupDidStartDownload, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidFinishDownload(notification:)), name: NSNotification.Name.WSPeerGroupDidFinishDownload, object: nil)
        
        let balance = self.wallet.balance()
        print("Balance: \(balance)")
        
        let allReceiveAddresses = self.wallet.allReceiveAddresses()
        print("allReceiveAddresses: \(allReceiveAddresses)")
        
        var addressesEncoded = NSMutableArray()
        var addressesHexEncoded = NSMutableArray()
        for address in allReceiveAddresses! {
            let encodedAddress = address as! WSAddress
            let privkey = self.wallet.privateKey(for: encodedAddress)
            let pubkey = self.wallet.publicKey(for: encodedAddress)
            addressesEncoded.add(privkey)
            addressesHexEncoded.add(pubkey)
        }
        
        print("addressesEncoded: \(addressesEncoded)")
        print("addressesHexEncoded: \(addressesHexEncoded)")
        
        let address = self.wallet.receiveAddress()
        print("receiveAddress: \(address)")
        
        let transactions = self.wallet.allTransactions()
        print("allTransactions: \(transactions)")
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
