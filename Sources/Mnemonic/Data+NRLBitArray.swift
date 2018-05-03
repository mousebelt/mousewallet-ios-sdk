//
//  Data+NRLBitArray.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/3/18.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import CryptoSwift

public extension UInt8 {
	public func nrl_bits() -> [String] {
		let totalBitsCount = MemoryLayout<UInt8>.size * 8
		
		var bitsArray = [String](repeating: "0", count: totalBitsCount)
		
		for j in 0 ..< totalBitsCount {
			let bitVal: UInt8 = 1 << UInt8(totalBitsCount - 1 - j)
			let check = self & bitVal
			
			if (check != 0) {
				bitsArray[j] = "1"
			}
		}
		return bitsArray
	}
}

public extension Data {
	public func nrl_toBitArray() -> [String] {
		var toReturn = [String]()
		for num: UInt8 in bytes {
			
			toReturn.append(contentsOf: num.nrl_bits())
		}
		return toReturn
	}
}
