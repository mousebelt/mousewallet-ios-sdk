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
    
    init(seed: Data, fTest: Bool) {
        var network: Network = .main(.stellar)
        if (fTest) {
            network = .test(.ethereum)
        }
        
        let cointype = network.coinType
        
        super.init(seed: seed,
                   network: network,
                   coinType: cointype,
                   seedKey: "ed25519 seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }
    
    func generatePublickey(seed: Seed) {
        
        var pubBuffer = [UInt8](repeating: 0, count: 32)
        var privBuffer = [UInt8](repeating: 0, count: 64)
        
        privBuffer.withUnsafeMutableBufferPointer { priv in
            pubBuffer.withUnsafeMutableBufferPointer { pub in
                seed.bytes.withUnsafeBufferPointer { seed in
                    ed25519_create_keypair(pub.baseAddress,
                                           priv.baseAddress,
                                           seed.baseAddress)
                }
            }
        }
        
        self.pubkeyData = Data(bytes: pubBuffer)
        self.wif = secret(seed: seed);
        self.address = accountId(bytes: pubBuffer);
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
