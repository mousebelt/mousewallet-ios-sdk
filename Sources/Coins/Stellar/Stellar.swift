//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ed25519C

class NRLStellar : NRLCoin{
    var pubkeyData: Data?;
    
    func accountId(bytes: [UInt8]) -> String {
        var versionByte = VersionByte.accountId.rawValue
        let versionByteData = Data(bytes: &versionByte, count: MemoryLayout.size(ofValue: versionByte))
        let payload = NSMutableData(data: versionByteData)
        payload.append(Data(bytes: bytes))
        let checksumedData = (payload as Data).crc16Data()
        
        return checksumedData.base32EncodedString
    }
    
    func secret(seed: Seed) -> String {
        return seed.secret
    }
    
    init(mnemonic: [String], seed: Data, fTest: Bool) {
        var network: NRLNetwork = .main(.stellar)
        if (fTest) {
            network = .test(.ethereum)
        }
        
        let cointype = network.coinType
        
        super.init(mnemonic: mnemonic,
                   seed: seed,
                   network: network,
                   coinType: cointype,
                   seedKey: "ed25519 seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }
    
    /*
     Now that you have a seed and public key, you can create an account. In order to prevent people from making a huge number of unnecessary accounts, each account must have a minimum balance of 1 lumen (lumens are the built-in currency of the Stellar network).[2] Since you don’t yet have any lumens, though, you can’t pay for an account. In the real world, you’ll usually pay an exchange that sells lumens in order to create a new account.[3] On Stellar’s test network, however, you can ask Friendbot, our friendly robot with a very fat wallet, to create an account for you.
     */
    
    func generatePublickey(seed: Seed) {
        
        let pair = KeyPair(seed: seed)
        
        self.pubkeyData = Data(bytes: pair.publicKey.bytes)
        self.wif = secret(seed: seed);
        self.address = accountId(bytes: pair.publicKey.bytes);
    }
    
    override func generateExternalKeyPair(at index: UInt32) throws {
        
        self.masterPrivateKey = NRLPrivateKey(seed: self.seed, privkey: generateMasterKey(), coin: self)
        self.pathPrivateKey = try path_derive(index: index)
        
        let stellarSeed = try! Seed(bytes: (self.pathPrivateKey?.raw.bytes)!)
        generatePublickey(seed: stellarSeed)
    }
    
    override func generateInternalKeyPair(at index: UInt32) throws {
        try generateExternalKeyPair(at: index)
    }
    
    // m/44'/coin_type'/0'/external
    private func path_derive(index: UInt32) throws -> NRLPrivateKey {
        return masterPrivateKey!
            .derived_Ed25519(at: 44)
            .derived_Ed25519(at: coinType)
            .derived_Ed25519(at: index)
    }
    
    override func getPublicKey() -> Data {
        return self.pubkeyData!
    }
}
