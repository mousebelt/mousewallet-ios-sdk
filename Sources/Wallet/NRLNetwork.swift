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
    case ethereum
    case neo
    case stellar
}

//coin_type
public enum NRLNetwork {
    case main(Coin)
    case test(Coin)
    //case `private`(Coin)
    
    // https://github.com/satoshilabs/slips/blob/master/slip-0044.md
    public var coinType: UInt32 {
        switch self  {
        case .main(.ethereum):
            return 60
        case .test(.ethereum):
            return 1
        case .main(.bitcoin):
            return 0
        case .test(.bitcoin):
            return 1
        case .main(.litecoin):
            return 2
        case .test(.litecoin):
            return 1
        case .main(.neo):
            return 888
        case .test(.neo):
            return 1
        case .main(.stellar):
            return 148
        case .test(.stellar):
            return 1
        }
    }
    
//    public var chainID: Int {
//        switch self {
//        case .main(.etheruem):
//            return 1
//        case .test(.etherum):
//            return 3
//        case .private(let chainID):
//            return chainID
//        }
//    }
    
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
