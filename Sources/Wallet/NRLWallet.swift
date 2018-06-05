//
//  NRLWallet.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import NRLWalletSDK.Private
import secp256k1
import CryptoSwift

public class NRLWallet {
    let coin: NRLCoin
    
    public init(seed: Data, network: Network) {
        switch network {
        case .main(.ethereum):
            coin = NRLEthereum(seed: seed, fTest: false)
            break
        case .test(.ethereum):
            coin = NRLEthereum(seed: seed, fTest: true)
            break
        case .main(.neo):
            coin = NRLNeo(seed: seed, fTest: false)
            break
        case .test(.neo):
            coin = NRLNeo(seed: seed, fTest: true)
            break
        case .main(.bitcoin):
            coin = NRLBitcoin(seed: seed, fTest: false)
            break
        case .test(.bitcoin):
            coin = NRLBitcoin(seed: seed, fTest: true)
            break
        case .main(.litecoin):
            coin = NRLLitecoin(seed: seed, fTest: false)
            break
        case .test(.litecoin):
            coin = NRLLitecoin(seed: seed, fTest: true)
            break
        case .main(.stellar):
            coin = NRLStellar(seed: seed, fTest: false)
            break
        case .test(.stellar):
            coin = NRLStellar(seed: seed, fTest: true)
            break
        default:
            coin = NRLEthereum(seed: seed, fTest: false)
            break
        }
    }
    
    public func generateExternalKeyPair(at index: UInt32) {
        try! self.coin.generateExternalKeyPair(at: index);
    }
    
    public func generateInternalKeyPair(at index: UInt32) throws {
        try! self.coin.generateInternalKeyPair(at: index);
    }
    
    public func getPublicKey() -> String {
        return self.coin.getPublicKey().toHexString();
    }
    
    public func getWIF() -> String {
        return self.coin.getPrivateKeyStr();
    }
    
    public func getAddress() -> String {
        return self.coin.getAddressStr();
    }
    
    // functions for own wallet and synchronizing as spv
    public func createOwnWallet(created: Date, fnew: Bool) {
        self.coin.createOwnWallet(created: created, fnew: fnew)
    }
    
    public func createPeerGroup() {
        self.coin.createPeerGroup()
    }
    
    public func connectPeers() -> Bool {
        return self.coin.connectPeers()
    }
    
    public func disConnectPeers() -> Bool {
        return self.coin.disConnectPeers()
    }
    
    public func startSyncing() -> Bool {
        return self.coin.startSyncing()
    }
    
    public func stopSyncing() -> Bool {
        return self.coin.stopSyncing()
    }
    
    public func isConnected() -> Bool {
        return self.coin.isConnected()
    }
    
    public func isDownloading() -> Bool {
        return self.coin.isDownloading()
    }
    
    public func getWalletBalance() -> UInt64 {
        return self.coin.getWalletBalance()
    }
    
    public func getAddressesOfWallet() -> NSMutableArray? {
        return self.coin.getAddressesOfWallet()
    }
    
    public func getPrivKeysOfWallet() -> NSMutableArray? {
        return self.coin.getPrivKeysOfWallet()
    }
    
    public func getPubKeysOfWallet() -> NSMutableArray? {
        return self.coin.getPubKeysOfWallet()
    }
    
    public func getReceiveAddress() -> String? {
        return self.coin.getReceiveAddress()
    }
    
    public func getAllTransactions() -> NSDictionary? {
        return self.coin.getAllTransactions()
    }
    
    public func sendTransaction(to: String, value: UInt64, fee: UInt64) -> Bool {
        return self.coin.sendTransaction(to: to, value: value, fee: fee)
    }
    
    public func signTransaction(to: String, value: UInt64, fee: UInt64) -> WSSignedTransaction? {
        return self.coin.signTransaction(to: to, value: value, fee: fee)
    }
    public func sendSignTransaction(tx: WSSignedTransaction) -> Bool {
        return self.coin.sendSignTransaction(tx: tx)
    }

}
