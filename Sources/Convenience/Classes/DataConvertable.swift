//
//  DataConvertable.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public protocol DataConvertable {
    static func +(lhs: Data, rhs: Self) -> Data
    static func +=(lhs: inout Data, rhs: Self)
}

extension DataConvertable {
    public static func +(lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }

    public static func +=(lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension UInt8: DataConvertable {}
extension UInt32: DataConvertable {}
