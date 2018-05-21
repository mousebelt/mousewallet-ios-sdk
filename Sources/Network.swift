//
//  Network.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public enum Coin {
    case bitcoin
    case litecoin
    case nem
    case ethereum
    case ethereumClassic
    case monero
    case zcash
    case lisk
    case bitcoinCash
    case neo
}

//coin_type
public enum Network {
    case main(Coin)
    case test
    
    public var privateKeyPrefix: UInt32 {
        switch self {
        case .main:
            return 0x0488ADE4
        case .test:
            return 0x04358394
        }
    }
    
    public var publicKeyPrefix: UInt32 {
        switch self {
        case .main:
            return 0x0488b21e
        case .test:
            return 0x043587cf
        }
    }
}
