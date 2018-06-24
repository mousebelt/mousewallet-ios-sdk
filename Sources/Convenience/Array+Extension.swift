//
//  Array+Extension.swift
//  NRLWalletSDK
//
//  Created by David Bala on 07/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import CSwiftyCommonCrypto

extension Array {
    public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            let endIndex = ($0.advanced(by: chunkSize) > self.count) ? self.count - $0 : chunkSize
            return Array(self[$0..<$0.advanced(by: endIndex)])
        }
    }
}

extension Array where Element == UInt8 {
    public var sha256: [UInt8] {
        let bytes = self
        
        let mutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256(bytes, CC_LONG(bytes.count), mutablePointer)
        
        let mutableBufferPointer = UnsafeMutableBufferPointer<UInt8>.init(start: mutablePointer, count: Int(CC_SHA256_DIGEST_LENGTH))
        let sha256Data = Data(buffer: mutableBufferPointer)
        
        mutablePointer.deallocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        
        return sha256Data.bytes
    }
}

extension Array where Element == UInt8 {
    public var hexString: String {
        return self.map { return String(format: "%x", $0) }.joined()
    }
    
    public var hexStringWithPrefix: String {
        return "0x\(hexString)"
    }
    
    public var fullHexString: String {
        return self.map { return String(format: "%02x", $0) }.joined()
    }
    
    public var fullHexStringWithPrefix: String {
        return "0x\(fullHexString)"
    }
    
    func toWordArray() -> [UInt32] {
        return arrayUtil_convertArray(self, to: UInt32.self)
    }
    
    mutating public func removeTrailingZeros() {
        for i in (0..<self.endIndex).reversed() {
            guard self[i] == 0 else {
                break
            }
            self.remove(at: i)
        }
    }
    
    func xor(other: [UInt8]) -> [UInt8] {
        assert(self.count == other.count)
        
        var result: [UInt8] = []
        for i in 0..<self.count {
            result.append(self[i] ^ other[i])
        }
        return result
    }
}

extension Array where Element == UInt32 {
    func toByteArrayFast() -> [UInt8] {
        return arrayUtil_convertArray(self, to: UInt8.self)
    }
    
    func toByteArray() -> [UInt8] {
        return arrayUtil_convertArray(self, to: UInt8.self)
    }
}

func arrayUtil_convertArray<S, T>(_ source: [S], to: T.Type) -> [T] {
    let count = source.count * MemoryLayout<S>.stride/MemoryLayout<T>.stride
    return source.withUnsafeBufferPointer {
        $0.baseAddress!.withMemoryRebound(to: T.self, capacity: count) {
            Array(UnsafeBufferPointer(start: $0, count: count))
        }
    }
}
