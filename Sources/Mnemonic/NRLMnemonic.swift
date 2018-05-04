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
enum NRLMnemonicError: Error
{
	case invalidStrength
	case unableToGetRandomData
	case unableToCreateSeedData
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
    
    /**
     Generate mnemonic
     Specify the strength and language
     return word list : array of String
     */
    public static func generateMnemonic(strength: Strength = .normal, language: NRLMnemonicLanguage = .english) -> [String] {
        let byteCount = strength.rawValue / 8
        var bytes = Data(count: byteCount)
        _ = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0) }
        return mnemonicString(entropy: bytes, language: language)
    }
    
    public static func mnemonicString(entropy: Data, language: NRLMnemonicLanguage = .english) -> [String] {
        let entropybits = String(entropy.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let hashBits = String(entropy.sha256().flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checkSum = String(hashBits.prefix((entropy.count * 8) / 32))
        
        let words = language.words()
        let concatenatedBits = entropybits + checkSum
        
        var mnemonic: [String] = []
        for index in 0..<(concatenatedBits.count / 11) {
            let startIndex = concatenatedBits.index(concatenatedBits.startIndex, offsetBy: index * 11)
            let endIndex = concatenatedBits.index(startIndex, offsetBy: 11)
            let wordIndex = Int(strtoul(String(concatenatedBits[startIndex..<endIndex]), nil, 2))
            mnemonic.append(String(words[wordIndex]))
        }
        
        return mnemonic
    }
    
    /**
     Get seed from mnemonic
     Return raw Data
     */
    public static func mnemonicToSeed(from: [String], withPassphrase passphrase: String = "") -> Data {
        let password = from.joined(separator: " ").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        return Crypto.PBKDF2SHA512(password, salt: salt)
    }
}
