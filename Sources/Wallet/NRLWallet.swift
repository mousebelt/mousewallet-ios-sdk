//
//  NRLWallet.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public class NRLWallet {
    let coin: NRLCoin
    
    public init(seed: Data, network: Network) {
        switch network {
        case .main(.ethereum):
            coin = NRLEthereum(seed: seed, fTest: true)
            break
        case .main(.neo):
            coin = NRLNeo(seed: seed, fTest: true)
            break
        default:
            coin = NRLEthereum(seed: seed, fTest: true)
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
        return self.coin.getPublicKey();
    }
    
    public func getWIF() -> String {
        return self.coin.getPrivateKey();
    }
    
    public func getAddress() -> String {
        return self.coin.getAddress();
    }

}
