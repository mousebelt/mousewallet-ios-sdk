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
import BigInt

public class NRLWallet {
    let coin: NRLCoin
    
    public init(mnemonic: [String], passphrase: String, network: NRLNetwork, symbol: String = "") {

        switch network {
        case .main(.ethereum):
            coin = NRLEthereum(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: false)
            break
        case .test(.ethereum):
            coin = NRLEthereum(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: true)
            break
        case .main(.neo):
            coin = NRLNeo(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: false)
            break
        case .test(.neo):
            coin = NRLNeo(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: true)
            break
        case .main(.bitcoin):
            coin = NRLBitcoin(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: false)
            break
        case .test(.bitcoin):
            coin = NRLBitcoin(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: true)
            break
        case .main(.litecoin):
            coin = NRLLitecoin(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: false)
            break
        case .test(.litecoin):
            coin = NRLLitecoin(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: true)
            break
        case .main(.stellar):
            coin = NRLStellar(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: false)
            break
        case .test(.stellar):
            coin = NRLStellar(symbol: symbol, mnemonic: mnemonic, passphrase: passphrase, fTest: true)
            break
//        default:
//            coin = NRLEthereum(seed: seed, fTest: false)
//            break
        }
    }
//
//    public func generateExternalKeyPair(at index: UInt32) {
//        try! self.coin.generateExternalKeyPair(at: index);
//    }
//    
//    public func generateInternalKeyPair(at index: UInt32) throws {
//        try! self.coin.generateInternalKeyPair(at: index);
//    }
    
//    public func getPublicKey() -> String {
//        return self.coin.getPublicKey().toHexString();
//    }
    
//    public func getWIF() -> String {
//        return self.coin.getPrivateKeyStr();
//    }
//
//    public func getAddress() -> String? {
//        return self.coin.getAddressStr();
//    }
    
    /*
     * Create own wallet
     * @params
     *   created: Set creation date for wallet. This is neccessary if import old wallet with seed.
     *   fnew: flag if make wallet newly or use current saved wallet. If this is set to true, original wallet in store will be wiped.
     *
    */
    public func createOwnWallet(created: Date, fnew: Bool) -> Bool {
        return self.coin.createOwnWallet(created: created, fnew: fnew)
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
    
    public func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {
        return self.coin.getWalletBalance(callback: callback)
    }
    
    public func getAddressesOfWallet() -> NSArray? {
        return self.coin.getAddressesOfWallet()
    }
    
    public func getPrivKeysOfWallet() -> NSArray? {
        return self.coin.getPrivKeysOfWallet()
    }
    
    public func getPubKeysOfWallet() -> NSArray? {
        return self.coin.getPubKeysOfWallet()
    }
    
    public func getReceiveAddress() -> String {
        return self.coin.getReceiveAddress()
    }
    
    public func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        return self.coin.getAccountTransactions(offset: offset, count: count, order: order, callback: callback)
    }
    
    //eterheum and ERC20 token
    public func sendTransaction(contractHash: String = "", to: String, value: BigUInt, fee: BigUInt, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.sendTransaction(contractHash: contractHash, to: to, value: value, fee: fee, callback: callback)
    }   
    
    public func signTransaction(contractHash: String = "", to: String, value: BigUInt, fee: BigUInt, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.signTransaction(contractHash: contractHash, to: to, value: value, fee: fee, callback: callback)
    }
    
    //bitcoin and litecoin
    public func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.sendTransaction(to: to, value: value, fee: fee, callback: callback)
    }
    
    public func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.signTransaction(to: to, value: value, fee: fee, callback: callback)
    }
    
    public func sendTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.sendTransaction(asset: asset, to: to, value: value, fee: fee, callback: callback)
    }
    
    public func sendSignTransaction(tx: WSSignedTransaction, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        return self.coin.sendSignTransaction(tx: tx, callback: callback)
    }
    
    public func sendTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.sendTransaction(to: to, value: value, fee: fee, callback: callback)
    }
    
    public func signTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.signTransaction(to: to, value: value, fee: fee, callback: callback)
    }

    public func signTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.coin.sendTransaction(asset: asset, to: to, value: value, fee: fee, callback: callback)
    }
}
