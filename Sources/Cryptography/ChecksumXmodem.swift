//
//  ChecksumXmodem.swift
//  StellarSDK
//
//  Created by Laptop on 2/8/18.
//  Copyright © 2018 Armonia. All rights reserved.
//

import Foundation

func ChecksumXmodem(_ buffer: [UInt8]) -> UInt16 {
    var crc  : UInt16 = 0x0
    var code : UInt16 = 0x0
    
    for byte in buffer {
        code  = crc  >> 8 & 0xFF
        code ^= UInt16(byte & 0xFF)
        code ^= code >> 4
        crc   = crc  << 8 & 0xFFFF
        crc  ^= code
        code  = code << 5 & 0xFFFF
        crc  ^= code
        code  = code << 7 & 0xFFFF
        crc  ^= code
    }
    
    return crc
}

// END
