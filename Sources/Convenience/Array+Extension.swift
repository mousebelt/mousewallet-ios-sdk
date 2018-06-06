//
//  Array+Extension.swift
//  NRLWalletSDK
//
//  Created by David Bala on 07/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

extension Array {
    public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            let endIndex = ($0.advanced(by: chunkSize) > self.count) ? self.count - $0 : chunkSize
            return Array(self[$0..<$0.advanced(by: endIndex)])
        }
    }
}
