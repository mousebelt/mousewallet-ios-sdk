//
//  NRLCoin.swift
//  NRLWalletSDK
//
//  Created by David Bala on 19/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation


class NRLCoin {
    // https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    // derived path:
    // m / purpose' / coin_type' / account' / change / address_index
    // Ex.  m / 44' / 60' / 0' / 0
    
    // https://github.com/satoshilabs/slips/blob/master/slip-0044.md

    var seed: Data;
    var masterPrivateKey: NRLPrivateKey?
    var pathPrivateKey: NRLPrivateKey?
    
    var network:Network
    var coinType: UInt32
    var seedKey: String
    var curve: String;
    
    var address: String?
    var wif: String?

    public init(seed: Data, network:Network, coinType: UInt32, seedKey: String, curve: String) {
        self.seed = seed;
        self.network = network
        self.coinType = coinType
        self.seedKey = seedKey
        self.curve = curve
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

    func getAddressStr() -> String {
        return self.address!;
    }

    func getPrivateKeyStr() -> String {
        return self.wif!;
    }
    
    func getSeedKey() -> Data {
        return self.seedKey.data(using: .ascii)!;
    }
    
    func generateMasterKey() -> Data {
        return Crypto.HMACSHA512(key: self.getSeedKey(), data: self.seed);
    }
    
    //these functions should be overrided by subcoins with generate address function
    func generateExternalKeyPair(at index: UInt32) throws {
        
        self.masterPrivateKey = NRLPrivateKey(seed: self.seed, privkey: generateMasterKey(), coin: self)
        self.pathPrivateKey = try generateExternalPrivateKey(at: index)
        generateAddress()
    }
    
    func generateInternalKeyPair(at index: UInt32) throws {
        self.masterPrivateKey = NRLPrivateKey(seed: self.seed, privkey: generateMasterKey(), coin: self)
        self.pathPrivateKey = try generateInteranlPrivateKey(at: index)
        generateAddress()
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
    func createOwnWallet() {}
    func saveWallet() {}
    func createPeerGroup() {}
    func connectPeers() -> Bool {return false}
    func disConnectPeers() -> Bool {return false}
    func startSyncing() -> Bool {return false}
    func stopSyncing() -> Bool {return false}
    func isConnected() -> Bool {return false}
    func isDownloading() -> Bool {return false}
    func getWalletBalance() -> UInt64 {return 0}
    func getAddressesOfWallet() -> NSMutableArray? {return nil}
    func getPrivKeysOfWallet() -> NSMutableArray? {return nil}
    func getPubKeysOfWallet() -> NSMutableArray? {return nil}
    func getReceiveAddress() -> String? {return ""}
    func getAllTransactions() -> NSDictionary? {return nil}
}
