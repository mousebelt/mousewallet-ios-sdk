//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

class NRLBitcoin : NRLCoin{
    let isTest: Bool;
    var btcpeer: BitcoinPeer?
    
    init(symbol: String, mnemonic: [String], passphrase: String, fTest: Bool) {
        self.isTest = fTest;

        var network: NRLNetwork = .main(.bitcoin)
        if (fTest) {
            network = .test(.bitcoin)
        }
        let cointype = network.coinType
        
        super.init(
            symbol: symbol,
            mnemonic: mnemonic,
            passphrase: passphrase,
            network: network,
            coinType: cointype,
            seedKey: "Bitcoin seed",
            curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
        self.btcpeer = BitcoinPeer(fTest: self.isTest)
    }
    
    var pubkeyhash: UInt8 {
        if (self.isTest) {
            return 0x6f
        }
        return 0x00
    }
    var privatekey: UInt8 {
        if (self.isTest) {
            return 0xef
        }
        return 0x80
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
    
    //override functions for own wallet and synchronizing as spv
    override func createOwnWallet(created: Date, fnew: Bool) -> Bool {
        guard let seed = self.seed else {
            DDLogDebug("createOwnWallet failed: no seed");
            return false;
        }
        self.btcpeer?.createWallet(seedData: seed, created: created, fnew: fnew)
        return true
    }

    override func createPeerGroup() {
        self.btcpeer?.createPeerGroup()
    }
    
    override func connectPeers() -> Bool {
        return (self.btcpeer?.connect())!
    }
    
    override func disConnectPeers() -> Bool {
        return (self.btcpeer?.disconnect())!
    }
    
    override func startSyncing() -> Bool {
        return (self.btcpeer?.startSync())!
    }
    
    override func stopSyncing() -> Bool {
        return (self.btcpeer?.stopSync())!
    }
    
    override func isConnected() -> Bool {
        return self.btcpeer!.isConnected()
    }
    
    override func isDownloading() -> Bool {
        return self.btcpeer!.isDownloading()
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {
        return self.btcpeer!.getWalletBalance(callback: callback)
    }
    
    override func getAddressesOfWallet() -> NSArray {
        return self.btcpeer!.getAddressesOfWallet()
    }
    
    
    override func getPrivKeysOfWallet() -> NSArray {
        return self.btcpeer!.getPrivKeysOfWallet()
    }
    
    override func getPubKeysOfWallet() -> NSArray {
        return self.btcpeer!.getPubKeysOfWallet()
    }
    
    override func getReceiveAddress() -> String {
        return self.btcpeer!.getReceiveAddress()
    }
    
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        self.btcpeer!.getAccountTransactions(offset: offset, count: count, order: order, callback: callback)
    }
    
    //transaction
    override func sendTransaction(contractHash: String, to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.btcpeer?.sendTransaction(to: to, value: value, fee: fee, callback: callback)
    }
    
    override func signTransaction(contractHash: String, to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.btcpeer?.signTransaction(to: to, value: value, fee: fee, callback: callback)
    }
    
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        self.btcpeer?.sendSignTransaction(tx: tx, callback: callback)
    }
}
