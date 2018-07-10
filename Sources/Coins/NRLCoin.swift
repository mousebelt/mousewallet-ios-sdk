//
//  NRLCoin.swift
//  NRLWalletSDK
//
//  Created by David Bala on 19/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import BigInt

class NRLCoin {
    // https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    // derived path:
    // m / purpose' / coin_type' / account' / change / address_index
    // Ex.  m / 44' / 60' / 0' / 0
    
    // https://github.com/satoshilabs/slips/blob/master/slip-0044.md

    var seed: Data?
    var mnemonic: [String]
    var masterPrivateKey: NRLPrivateKey?
    var pathPrivateKey: NRLPrivateKey?
    
    var coinsymbol: String
    
    var network: NRLNetwork
    var coinType: UInt32
    var seedKey: String
    var curve: String
    var passphrase: String
    
    var address: String?
    var wif: String?

    public init(symbol:String, mnemonic: [String], passphrase: String, network: NRLNetwork, coinType: UInt32, seedKey: String, curve: String) {
        self.coinsymbol = symbol;
        self.mnemonic = mnemonic
        self.network = network
        self.coinType = coinType
        self.seedKey = seedKey
        self.curve = curve
        self.passphrase = passphrase
        
        do {
            self.seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: passphrase)
            DDLogDebug("\nseed = \(String(describing: seed?.hexEncodedString()))")

        } catch let error {
            DDLogDebug("Cannot generate seed: \(error)")
            return
        }
    }
    //should be overrided
    func generateAddress() {
        
    }
    //should be overrided
    func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        return Data()
    }
    
    func getPublicKey() -> Data {
        return self.pathPrivateKey!.nrlPublicKey().raw;
    }

    func getAddressStr() -> String? {
        return self.address;
    }

    func getPrivateKeyStr() -> String? {
        return self.wif;
    }
    
    func getSeedKey() -> Data {
        return self.seedKey.data(using: .ascii)!;
    }
    
    func generateMasterKey() -> Data? {
        guard let seed = self.seed else { return nil }
        return Crypto.HMACSHA512(key: self.getSeedKey(), data: seed);
    }
    
    //these functions should be overrided by subcoins with generate address function
    func generateExternalKeyPair(at index: UInt32) throws {
        guard let seed = self.seed else { return }
        guard let masterkey = generateMasterKey() else { return }
        DDLogDebug("masterkey: \(masterkey.toHexString())")
        
        self.masterPrivateKey = NRLPrivateKey(seed: seed, privkey: masterkey, coin: self)
        DDLogDebug("masterPrivateKey: \(String(describing: self.masterPrivateKey?.raw.toHexString()))")
        DDLogDebug("masterPrivateKey chaincodd: \(String(describing: self.masterPrivateKey?.chainCode.toHexString()))")
        self.pathPrivateKey = try generateExternalPrivateKey(at: index)
        DDLogDebug("pathPrivateKey: \(String(describing: self.pathPrivateKey?.raw.toHexString()))")
    }
    
    func generateInternalKeyPair(at index: UInt32) throws {
        guard let seed = self.seed else { return }
        guard let masterkey = generateMasterKey() else { return }
        
        self.masterPrivateKey = NRLPrivateKey(seed: seed, privkey: masterkey, coin: self)
        self.pathPrivateKey = try generateInteranlPrivateKey(at: index)
    }

    // MARK: - Private Methods
    
    private func generateExternalPrivateKey(at index: UInt32) throws -> NRLPrivateKey {
        return try externalPrivateKey().derived(at: index)
    }
    
    private func generateInteranlPrivateKey(at index: UInt32) throws -> NRLPrivateKey {
        return try internalPrivateKey().derived(at: index)
    }
    
    private func externalPrivateKey() throws -> NRLPrivateKey {
        let key :NRLPrivateKey = try privateKey(change: .external)
        return key
    }
    
    private func internalPrivateKey() throws -> NRLPrivateKey {
        let key :NRLPrivateKey = try privateKey(change: .internal)
        return key
    }
    
    private enum Change: UInt32 {
        case external = 0
        case `internal` = 1
    }
    
    // m/44'/coin_type'/0'/external
    private func privateKey(change: Change) throws -> NRLPrivateKey {
        return try masterPrivateKey!
            .derived(at: 44, hardens: true)
            .derived(at: coinType, hardens: true)
            .derived(at: 0, hardens: true)
            .derived(at: change.rawValue)
    }
    
    
    //override functions for own wallet and synchronizing as spv
    func createOwnWallet(created: Date, fnew: Bool)  -> Bool {return false}
    func createPeerGroup() {}
    func connectPeers() -> Bool {return false}
    func disConnectPeers() -> Bool {return false}
    func startSyncing() -> Bool {return false}
    func stopSyncing() -> Bool {return false}
    func isConnected() -> Bool {return false}
    func isDownloading() -> Bool {return false}
    func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {}
    func getAddressesOfWallet() -> NSArray? {return nil}
    func getPrivKeysOfWallet() -> NSArray? {return nil}
    func getPubKeysOfWallet() -> NSArray? {return nil}
    func getReceiveAddress() -> String {return ""}
    func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {}
    //transaction for ethereum and ERC20 tokens. value and fee is wei unit(1E-18)
    func sendTransaction(contractHash: String, to: String, value: BigUInt, fee: BigUInt, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    func signTransaction(contractHash: String, to: String, value: BigUInt, fee: BigUInt, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    
    //transaction for bitcoin and litecoin. value and fee is satoshi and litoshi(1E-8) unit
    func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    
    func sendTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    func signTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    
    func sendTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    func signTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    
    func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
}
