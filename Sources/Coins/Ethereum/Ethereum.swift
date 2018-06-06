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
    
    init(seed: Data, fTest: Bool) {
        var network: Network = .main(.ethereum)
        if (fTest) {
            network = .test(.ethereum)
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
    
    override func getWalletBalance() -> UInt64 {
        return 0
    }
    
    override func getAddressesOfWallet() -> NSMutableArray? {return nil}
    override func getPrivKeysOfWallet() -> NSMutableArray? {return nil}
    override func getPubKeysOfWallet() -> NSMutableArray? {return nil}
    override func getReceiveAddress() -> String? {return ""}
    override func getAllTransactions() -> NSDictionary? {
        
        return nil
    }
    //transaction
    override func sendTransaction(to: String, value: UInt64, fee: UInt64) -> Bool {
        firstly {
            self.web3.eth.getTransactionCount(address: (self.privKey?.address)!, block: .latest)
            }.then { nonce in
                Promise { seal in
                    var tx = try EthereumTransaction(
                        nonce: nonce,
                        gasPrice: EthereumQuantity(quantity:BigUInt(fee)),
                        gasLimit: 21000,
                        to: EthereumAddress(hex: to, eip55: true),
                        value: EthereumQuantity(quantity: BigUInt(value)),
                        chainId: 1
                    )
                    try tx.sign(with: self.privKey!)
                    seal.resolve(tx, nil)
                }
            }.then { tx in
                self.web3.eth.sendRawTransaction(transaction: tx)
            }.done { hash in
                print(hash)
            }.catch { error in
                print(error)
        }
        return false
    }
    override func signTransaction(to: String, value: UInt64, fee: UInt64) -> WSSignedTransaction? {return nil}
    override func sendSignTransaction(tx: WSSignedTransaction) -> Bool {return false}
}
