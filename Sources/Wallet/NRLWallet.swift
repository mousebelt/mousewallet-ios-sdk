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
    
    public init(mnemonic: String, seed: Data, network: Network) {
        switch network {
        case .main(.ethereum):
            coin = NRLEthereum(seed: seed, fTest: false)
            break
        case .main(.neo):
            coin = NRLNeo(seed: seed, fTest: false)
            break
        case .main(.bitcoin):
            coin = NRLBitcoin(mnemonic:mnemonic, seed: seed, fTest: false)
            break
        case .main(.litecoin):
            coin = NRLLitecoin(seed: seed, fTest: false)
            break
        case .main(.stellar):
            coin = NRLStellar(seed: seed, fTest: false)
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

}
