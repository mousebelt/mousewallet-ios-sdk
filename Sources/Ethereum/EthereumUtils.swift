//
//  utils.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

public typealias ENRLEthereumUtils = NRLEthereum.Utils

extension NRLEthereum {
    public struct Utils {
    }
}

extension NRLEthereum.Utils {
    public static func publicToAddressData(_ publicKey: Data) -> Data? {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {return nil}
            return publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                return nil
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            return nil
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }

    public static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
        guard let addressData = NRLEthereum.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(address)
    }
    
    public static func publicToAddressStr(_ publicKey: Data) -> String? {
        guard let addressData = NRLEthereum.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return address
    }

    public static func publicToAddressString(_ publicKey: Data) -> String? {
        guard let addressData = NRLEthereum.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return address
    }

    public static func addressDataToString(_ addressData: Data) -> String {
        return addressData.toHexString().addHexPrefix().lowercased()
    }
}
