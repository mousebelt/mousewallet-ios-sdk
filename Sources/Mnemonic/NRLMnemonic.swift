//
//  NRLMnemonic.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/3/18.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import UIKit
import CryptoSwift
import Security

/**
 Enumerates of languages supported by NRLWalletSDK
 */
public enum NRLMnemonicLanguage {
	case english
	case chinese
    case korean
    case spanish
    case french
    case italian
    case japanese
	
	func words() -> [String] {
		switch self {
		case .english:
			return String.englishMnemonics
		case .chinese:
			return String.chineseMnemonics
        case .korean:
            return String.koreanMnemonics
        case .spanish:
            return String.spanishMnemonics
        case .french:
            return String.frenchMnemonics
        case .italian:
            return String.italianMnemonics
        case .japanese:
            return String.japaneseMnemonics
		}
	}
}

/**
 Enumerates of NSErrors supported by NRLWalletSDK
 */
public enum NRLMnemonicError: Error
{
	case invalidStrength
	case unableToGetRandomData
	case unableToCreateSeedData
    case invalidMnemonic
}

/**
 `NRLMnemonic` class to handle mnemonic/seed related apis.
 
 - Authors: David Bala
 */
public class NRLMnemonic: NSObject {
	
    public enum Strength: Int {
        case normal = 128
        case hight = 256
    }
    
    public static func mnemonicString(from hexString: String, language: NRLMnemonicLanguage) throws -> [String] {
        let seedData = hexString.ck_mnemonicData()
        let hashData = seedData.sha256()
        let checkSum = hashData.nrl_toBitArray()
        var seedBits = seedData.nrl_toBitArray()
        
        for i in 0..<seedBits.count / 32 {
            seedBits.append(checkSum[i])
        }
        
        let words = language.words()
        
        let mnemonicCount = seedBits.count / 11
        var mnemonic = [String]()
        for i in 0..<mnemonicCount {
            let length = 11
            let startIndex = i * length
            let subArray = seedBits[startIndex..<startIndex + length]
            let subString = subArray.joined(separator: "")
            
            let index = Int(strtoul(subString, nil, 2))
            mnemonic.append(words[index])
        }
        return mnemonic
    }
    
    public static func mnemonicToSeed(from mnemonic: [String], withPassphrase: String = "") throws -> Data {
        
        func normalized(string: String) throws -> Data? {
            guard let data = string.data(using: .utf8, allowLossyConversion: true) else {
                throw NRLMnemonicError.invalidMnemonic
            }
            
            guard let dataString = String(data: data, encoding: .utf8) else {
                throw NRLMnemonicError.invalidMnemonic
            }
            
            guard let normalizedData = dataString.data(using: .utf8, allowLossyConversion: false) else {
                throw NRLMnemonicError.invalidMnemonic
            }
            return normalizedData
        }
        
        guard let normalizedData = try normalized(string: mnemonic.joined(separator: " ")) else {
            throw NRLMnemonicError.invalidMnemonic
        }
        
        guard let saltData = try normalized(string: "mnemonic" + withPassphrase) else {
            throw NRLMnemonicError.invalidMnemonic
        }
        
        let password = normalizedData.bytes
        let salt = saltData.bytes
        
        do {
            let bytes = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 2048, variant: .sha512).calculate()
            return Data(bytes: bytes)
        } catch {
            throw NRLMnemonicError.invalidMnemonic
        }
    }
    
    public static func generateMnemonic(strength: Strength = .normal, language: NRLMnemonicLanguage = .english) throws -> [String] {
        guard strength.rawValue % 32 == 0 else {
            throw NRLMnemonicError.invalidStrength
        }
        
        let count = strength.rawValue / 8
        let bytes = Array<UInt8>(repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, UnsafeMutablePointer<UInt8>(mutating: bytes))

        if status != -1 {
            let data = Data(bytes: bytes)
            let hexString = data.toHexString()
            
            return try mnemonicString(from: hexString, language: language)
        }
        
        throw NRLMnemonicError.unableToGetRandomData
    }
}
