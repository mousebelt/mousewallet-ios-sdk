//
//  BitcoinNetwork.swift
//  NRLWalletSDK
//
//  Created by David Bala on 29/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import NRLWalletSDK.Private


public class BitcoinPeer {
    let isTest: Bool
    let parameters: WSParameters

    let walletPath: String
    let dbPath: String
    
    var downloader: WSBlockChainDownloader?
    var peerGroup: WSPeerGroup?
    var wallet: WSHDWallet?
    
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
        self.dbPath = documentsDirectory.appendingPathComponent("nrlbtc.sql").path
    }
    
    func getWalletBalance() -> UInt64 {
        self.wallet?.recalculateSpendsAndBalance()
        let balance = self.wallet?.balance()
        DDLogDebug("Balance: \(String(describing: balance))")
        
        return balance!
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
    
    func getAllTransactions() -> NSDictionary {
        let transactions = self.wallet?.allTransactions()
        DDLogDebug("allTransactions: \(String(describing: transactions))")
        
        return transactions! as NSDictionary
    }
    
    func createWallet(seedData: Data) {
        self.wallet = WSHDWallet(parameters: self.parameters, seeddata: seedData)
        

    }
    
    func createPeerGroup() {
        let store = WSMemoryBlockStore(parameters: self.parameters)
        self.downloader = WSBlockChainDownloader(store: store, wallet: self.wallet)
        
        self.peerGroup = WSPeerGroup(parameters: self.parameters)
        self.peerGroup?.maxConnections = 10;

    }
    
    func connect() -> Bool {
        if (!(self.peerGroup?.isStarted())!) {
            if (self.peerGroup?.startConnections())! {
                DDLogVerbose("peers connected")
                return true
            }
        }
        
        return false
    }
    
    func disconnect() -> Bool {
        if ((self.peerGroup?.isStarted())!) {
            if (self.peerGroup?.stopConnections())! {
                DDLogVerbose("peers disconnected")
                return true
            }
        }
        return false
    }
    
    func startSync() -> Bool {
        if (!(self.peerGroup?.isDownloading())!) {
            if (self.peerGroup?.startDownload(with: self.downloader))! {
                DDLogVerbose("start syncing")
                return true
            }
        }
        return false
    }
    
    func stopSync() -> Bool {
        if ((self.peerGroup?.isDownloading())!) {
            self.peerGroup?.stopDownload()
            DDLogVerbose("stop syncing")
            return true
        }
        return false
    }
    
    func isConnected() -> Bool {
        return (self.peerGroup?.isStarted())!
    }
    
    func isDownloading() -> Bool {
        return (self.peerGroup?.isDownloading())!
    }
}
