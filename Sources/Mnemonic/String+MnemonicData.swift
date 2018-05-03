//
//  String+MnemonicData.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/3/18.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

public extension String
{
	public func ck_mnemonicData() -> Data {
        
		let length = self.count
        
		let dataLength = length / 2
		var dataToReturn = Data(capacity: dataLength)
		
		var index = 0
		var chars = ""
		for char in self {
			chars += String(char)
			if index % 2 == 1 {
				let i: UInt8 = UInt8(strtoul(chars, nil, 16))
				dataToReturn.append(i)
				chars = ""
			}
			index += 1
		}
		
		return dataToReturn
	}
}
