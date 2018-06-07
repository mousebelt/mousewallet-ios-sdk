//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import PromiseKit
import Web3
import BigInt

class NRLEthereum : NRLCoin{
    let web3 = Web3(rpcURL: urlWeb3Provider)
    var privKey: EthereumPrivateKey?
    var chainid: EthereumQuantity //1 for mainnet. 3 for ropsten. 4 for rinkeby. 42 for kovan.
    
    init(seed: Data, fTest: Bool) {
        var network: Network = .main(.ethereum)
        self.chainid = 1
        if (fTest) {
            network = .test(.ethereum)
            self.chainid = 3
        }
        
        let cointype = network.coinType
        
        super.init(seed: seed,
                   network: network,
                   coinType: cointype,
                   seedKey: "Bitcoin seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }

    override func generatePublickeyFromPrivatekey(privateKey: Data) throws -> Data {
        let publicKey = Crypto.generatePublicKey(data: privateKey, compressed: true)
        return publicKey;
    }
    
    /// Address data generated from public key in data format
    func addressDataFromPublicKey(publicKey: Data) -> Data {
        return Crypto.hashSHA3_256(publicKey.dropFirst()).suffix(20)
    }
    
    override func generateAddress() {
        let publicKey = Crypto.generatePublicKey(data: (self.pathPrivateKey?.raw)!, compressed: false)
        self.address = Address(data: addressDataFromPublicKey(publicKey: publicKey)).string
        self.wif = self.pathPrivateKey?.raw.toHexString()
    }
    
    override func createOwnWallet(created: Date, fnew: Bool) {
        do {
            try generateExternalKeyPair(at: 0)
        
            let privateKey = getPrivateKeyStr()
            
            self.privKey = try? EthereumPrivateKey(hexPrivateKey: privateKey)
        
            DDLogDebug("\nEthereum private key = \(String(describing: privateKey))")
            DDLogDebug("Ethereum address1 = \(String(describing: self.privKey?.address.hex(eip55: true)))")

        } catch {
            DDLogDebug(error as! String)
        }
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: String) -> ()) {
        firstly {
            web3.eth.getBalance(address: (self.privKey?.address)!, block: .latest)
            }.done { balance in
                let ethBalance = Double(balance.quantity) / Double(1.eth)
                DDLogDebug("balance: \(ethBalance)")
                callback(NRLWalletSDKError.nrlSuccess, ethBalance.description)
            }.catch { error in
                DDLogDebug("Failed to get: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), "")
        }
    }
    
    override func getAddressesOfWallet() -> NSMutableArray? {
        let result = NSMutableArray()
        result.add(self.privKey?.address as Any)
        return result
    }
    override func getPrivKeysOfWallet() -> NSMutableArray? {
        let result = NSMutableArray()
        result.add(self.privKey as Any)
        return result
    }
    override func getPubKeysOfWallet() -> NSMutableArray? {return nil}
    override func getReceiveAddress() -> String? {
        return self.privKey?.address.hex(eip55: false)
    }
    override func getAllTransactions() -> NSDictionary? {
        
        return nil
    }
    //transaction
    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        firstly {
            self.web3.eth.getTransactionCount(address: (self.privKey?.address)!, block: .latest)
            }.then { nonce in
                return Promise { seal in
                    var tx = try EthereumTransaction(
                        nonce: nonce,
                        gasPrice: EthereumQuantity(quantity:BigUInt(fee)),
                        gasLimit: 21000,
                        to: EthereumAddress(hex: to, eip55: false),
                        value: EthereumQuantity(quantity: BigUInt(value)),
                        chainId: self.chainid
                    )
                    DDLogDebug("chainid: \(tx.chainId.hex())")
                    DDLogDebug("nonce: \(tx.nonce.hex())")
                    DDLogDebug("to: \(tx.to.hex(eip55: false))")
                    DDLogDebug("value: \(tx.value.hex())")
                    DDLogDebug("gasPrice: \(tx.gasPrice.hex())")
                    
                    try tx.sign(with: self.privKey!)

                    DDLogDebug("r: \(tx.r.hex())")
                    DDLogDebug("s: \(tx.s.hex())")
                    DDLogDebug("v: \(tx.v.hex())")
                    seal.resolve(tx, nil)
                }
            }.then { tx in
                self.web3.eth.sendRawTransaction(transaction: tx)
            }.done { hash in
                DDLogDebug("Sent transaction: \(hash.hex())")
                callback(NRLWalletSDKError.nrlSuccess, hash.hex() as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        firstly {
            self.web3.eth.getTransactionCount(address: (self.privKey?.address)!, block: .latest)
            }.then { nonce in
                return Promise { seal in
                    var tx = try EthereumTransaction(
                        nonce: nonce,
                        gasPrice: EthereumQuantity(quantity:BigUInt(fee)),
                        gasLimit: 21000,
                        to: EthereumAddress(hex: to, eip55: false),
                        value: EthereumQuantity(quantity: BigUInt(value)),
                        chainId: self.chainid
                    )
                    DDLogDebug("chainid: \(tx.chainId.hex())")
                    DDLogDebug("nonce: \(tx.nonce.hex())")
                    DDLogDebug("to: \(tx.to.hex(eip55: false))")
                    DDLogDebug("value: \(tx.value.hex())")
                    DDLogDebug("gasPrice: \(tx.gasPrice.hex())")
                    
                    try tx.sign(with: self.privKey!)
                    
                    DDLogDebug("r: \(tx.r.hex())")
                    DDLogDebug("s: \(tx.s.hex())")
                    DDLogDebug("v: \(tx.v.hex())")
                    seal.resolve(tx, nil)
                }
            }.done { tx in
                callback(NRLWalletSDKError.nrlSuccess, tx as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback(NRLWalletSDKError.transactionError(.signFailed(error)), 0)
        }
    }
    
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let transactionSigned = tx as! EthereumTransaction
        firstly {
            self.web3.eth.sendRawTransaction(transaction: transactionSigned)
            }.done { hash in
                DDLogDebug("Sent transaction: \(hash.hex())")
                callback(NRLWalletSDKError.nrlSuccess, hash.hex() as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)        }
    }
}
