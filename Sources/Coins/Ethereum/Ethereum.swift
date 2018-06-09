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
import Alamofire
import ObjectMapper

class NRLEthereum : NRLCoin{
//    let web3 = Web3(rpcURL: urlWeb3Provider)
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
//        firstly {
//            web3.eth.getBalance(address: (self.privKey?.address)!, block: .latest)
//            }.done { balance in
//                let ethBalance = Double(balance.quantity) / Double(1.eth)
//                DDLogDebug("balance: \(ethBalance)")
//                callback(NRLWalletSDKError.nrlSuccess, ethBalance.description)
//            }.catch { error in
//                DDLogDebug("Failed to get: \(error)")
//                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), "")
//        }
        
        let address = self.privKey!.address.hex(eip55: false)
        let url = "\(urlEtherServer)/api/v1/balance/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                let resObj = Mapper<GetBalanceResponse>().map(JSONObject: res.data)
                let balance: String = (resObj?.balance)!
                DDLogDebug("balance: \(balance)")
                callback(NRLWalletSDKError.nrlSuccess, balance)
            }.catch { error in
                callback((error as? NRLWalletSDKError)!, "")
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
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        let address = self.privKey!.address.hex(eip55: false)
        let url = "\(urlEtherServer)/api/v1/address/txs/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url, parameters: ["offset": offset, "count": count, "order": order])
            }.done { res in
                let resObj = Mapper<TransactionResponse>().map(JSONObject: res.data)
                
                callback(NRLWalletSDKError.nrlSuccess, resObj!)
            }.catch { error in
                callback((error as? NRLWalletSDKError)!, 0)
        }

    }
//    //transaction
//    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
//        firstly {
//            self.web3.eth.getTransactionCount(address: (self.privKey?.address)!, block: .latest)
//            }.then { nonce in
//                return Promise { seal in
//                    var tx = try EthereumTransaction(
//                        nonce: nonce,
//                        gasPrice: EthereumQuantity(quantity:BigUInt(fee)),
//                        gasLimit: 21000,
//                        to: EthereumAddress(hex: to, eip55: false),
//                        value: EthereumQuantity(quantity: BigUInt(value)),
//                        chainId: self.chainid
//                    )
//                    DDLogDebug("chainid: \(tx.chainId.hex())")
//                    DDLogDebug("nonce: \(tx.nonce.hex())")
//                    DDLogDebug("to: \(tx.to.hex(eip55: false))")
//                    DDLogDebug("value: \(tx.value.hex())")
//                    DDLogDebug("gasPrice: \(tx.gasPrice.hex())")
//
//                    try tx.sign(with: self.privKey!)
//
//                    DDLogDebug("r: \(tx.r.hex())")
//                    DDLogDebug("s: \(tx.s.hex())")
//                    DDLogDebug("v: \(tx.v.hex())")
//                    seal.resolve(tx, nil)
//                }
//            }.then { tx in
//                self.web3.eth.sendRawTransaction(transaction: tx)
//            }.done { hash in
//                DDLogDebug("Sent transaction: \(hash.hex())")
//                callback(NRLWalletSDKError.nrlSuccess, hash.hex() as Any)
//            }.catch { error in
//                DDLogDebug("Failed to send: \(error)")
//                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
//        }
//    }
//    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
//        firstly {
//            self.web3.eth.getTransactionCount(address: (self.privKey?.address)!, block: .latest)
//            }.then { nonce in
//                return Promise { seal in
//                    var tx = try EthereumTransaction(
//                        nonce: nonce,
//                        gasPrice: EthereumQuantity(quantity:BigUInt(fee)),
//                        gasLimit: 21000,
//                        to: EthereumAddress(hex: to, eip55: false),
//                        value: EthereumQuantity(quantity: BigUInt(value)),
//                        chainId: self.chainid
//                    )
//                    DDLogDebug("chainid: \(tx.chainId.hex())")
//                    DDLogDebug("nonce: \(tx.nonce.hex())")
//                    DDLogDebug("to: \(tx.to.hex(eip55: false))")
//                    DDLogDebug("value: \(tx.value.hex())")
//                    DDLogDebug("gasPrice: \(tx.gasPrice.hex())")
//
//                    try tx.sign(with: self.privKey!)
//
//                    DDLogDebug("r: \(tx.r.hex())")
//                    DDLogDebug("s: \(tx.s.hex())")
//                    DDLogDebug("v: \(tx.v.hex())")
//                    seal.resolve(tx, nil)
//                }
//            }.done { tx in
//                callback(NRLWalletSDKError.nrlSuccess, tx as Any)
//            }.catch { error in
//                DDLogDebug("Failed to send: \(error)")
//                callback(NRLWalletSDKError.transactionError(.signFailed(error)), 0)
//        }
//    }
//
//    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
//        let transactionSigned = tx as! EthereumTransaction
//        firstly {
//            self.web3.eth.sendRawTransaction(transaction: transactionSigned)
//            }.done { hash in
//                DDLogDebug("Sent transaction: \(hash.hex())")
//                callback(NRLWalletSDKError.nrlSuccess, hash.hex() as Any)
//            }.catch { error in
//                DDLogDebug("Failed to send: \(error)")
//                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)        }
//    }
    
    //transaction
    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let address = self.privKey!.address.hex(eip55: false)
        var url = "\(urlEtherServer)/api/v1/address/gettransactioncount/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.then { res in
                return Promise<VCoinResponse> { seal in
                    let nonce: UInt = res.data as! UInt

                    var tx = try EthereumTransaction(
                        nonce: EthereumQuantity(quantity: BigUInt(nonce)),
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

                    let newtx = try tx.sign(with: self.privKey!)

                    DDLogDebug("r: \(newtx.r.hex())")
                    DDLogDebug("s: \(newtx.s.hex())")
                    DDLogDebug("v: \(newtx.v.hex())")
                    
                    DDLogDebug("inputdata: \(tx.data.hex())")

                    url = "\(urlEtherServer)/api/v1/sendsignedtransaction"
                    let rawData: Bytes = try! RLPEncoder().encode(newtx.rlp())
                    DDLogDebug("rawDAta: \(String(describing: rawData.toHexString()))")
                    
                    sendRequest(responseObject:VCoinResponse.self, url: url, method: .post,
                                parameters: ["raw": String(describing: rawData.toHexString())])
                        .done {res2 in
                            DDLogDebug("\(res2)")
                            seal.fulfill(res2)
                            }
                        .catch { error in
                            seal.reject(error)
                    }
                }
            }.done { res in
                let resObj = Mapper<SendSignedTransactionResponse>().map(JSONObject: res.data)
                let hash: String = (resObj?.transactionHash)!
            
                callback(NRLWalletSDKError.nrlSuccess, hash as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
    
    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let address = self.privKey!.address.hex(eip55: false)
        let url = "\(urlEtherServer)/api/v1/address/gettransactioncount/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                let nonce: UInt = res.data as! UInt
                
                var tx = try EthereumTransaction(
                    nonce: EthereumQuantity(quantity: BigUInt(nonce)),
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
                
                let newtx: EthereumTransaction = try tx.sign(with: self.privKey!)
                
                DDLogDebug("r: \(newtx.r.hex())")
                DDLogDebug("s: \(newtx.s.hex())")
                DDLogDebug("v: \(newtx.v.hex())")
                
                DDLogDebug("inputdata: \(tx.data.hex())")
                
                callback(NRLWalletSDKError.nrlSuccess, newtx as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
  
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let transactionSigned = tx as! EthereumTransaction
        let url = "\(urlEtherServer)/api/v1/sendsignedtransaction"
        let rawData: Bytes = try! RLPEncoder().encode(transactionSigned.rlp())
        DDLogDebug("rawDAta: \(String(describing: rawData.toHexString()))")
        
        firstly {
                sendRequest(responseObject:VCoinResponse.self, url: url, method: .post,
                            parameters: ["raw": String(describing: rawData.toHexString())])
            }.done { res in
                let resObj = Mapper<SendSignedTransactionResponse>().map(JSONObject: res.data)
                let hash: String = (resObj?.transactionHash)!
                
                callback(NRLWalletSDKError.nrlSuccess, hash as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
        }
    }
}
