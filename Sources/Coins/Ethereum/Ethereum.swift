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
    let web3 = Web3(rpcURL: "") //this is only used for contract transaction sign.
    var privKey: EthereumPrivateKey?
    var chainid: EthereumQuantity //1 for mainnet. 3 for ropsten. 4 for rinkeby. 42 for kovan.
    var urlServer: String
    
    init(symbol: String, mnemonic: [String], passphrase: String, fTest: Bool) {
        
        var network: NRLNetwork = .main(.ethereum)
        self.chainid = 1
        self.urlServer = urlEtherServer
        if (fTest) {
            network = .test(.ethereum)
            self.chainid = 3
            self.urlServer = urlEtherTestServer
        }
        
        let cointype = network.coinType
        
        super.init(symbol: symbol,
                   mnemonic: mnemonic,
                   passphrase: passphrase,
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
    
//    override func generateAddress() {
//        let publicKey = Crypto.generatePublicKey(data: (self.pathPrivateKey?.raw)!, compressed: false)
//        self.address = Address(data: addressDataFromPublicKey(publicKey: publicKey)).string
//        self.wif = self.pathPrivateKey?.raw.toHexString()
//    }
    
    override func getPrivateKeyStr() -> String? {
        return self.pathPrivateKey?.raw.toHexString()
    }
    
    override func createOwnWallet(created: Date, fnew: Bool)  -> Bool {
        do {
            try generateExternalKeyPair(at: 0)
        
            let privateKey = getPrivateKeyStr()
            
            self.privKey = try? EthereumPrivateKey(hexPrivateKey: privateKey!)
        
            DDLogDebug("\nEthereum private key = \(String(describing: privateKey))")
            DDLogDebug("Ethereum address1 = \(String(describing: self.privKey?.address.hex(eip55: true)))")
            return true

        } catch {
            DDLogDebug(error as! String)
            return false
        }
    }
    
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ()) {
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

        let url = "\(self.urlServer)/api/v1/balance/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                let resObj = Mapper<ETHGetBalanceResponse>().map(JSONObject: res.data)
                let balances = (resObj?.balances)!
                DDLogDebug("balance: \(balances)")
                callback(NRLWalletSDKError.nrlSuccess, balances)
            }.catch { error in
                callback((error as? NRLWalletSDKError)!, "")
        }
    }
    
    override func getAddressesOfWallet() -> NSArray? {
        let result = NSMutableArray()
        result.add(self.privKey?.address as Any)
        return result
    }
    override func getPrivKeysOfWallet() -> NSArray? {
        let result = NSMutableArray()
        result.add(self.privKey as Any)
        return result
    }
    override func getPubKeysOfWallet() -> NSArray? {return nil}
    override func getReceiveAddress() -> String {
        guard let key = self.privKey else {
            return ""
        }
        
        return key.address.hex(eip55: false)
    }
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {
        let address = self.privKey!.address.hex(eip55: false)
        let url = "\(self.urlServer)/api/v1/address/txs/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url, parameters: ["offset": offset, "count": count, "order": order])
            }.done { res in
                let resObj = Mapper<ETHGetTransactionsResponse>().map(JSONObject: res.data)
                
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
//                callback(NRLWalletSDKError.transactionError(.transactionFailed(error)), 0)
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
    override func sendTransaction(contractHash: String, to: String, value: BigUInt, fee: BigUInt, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let address = self.privKey!.address.hex(eip55: false)
        var url = "\(self.urlServer)/api/v1/address/gettransactioncount/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.then { res in
                return Promise<VCoinResponse> { seal in
                    let nonce: UInt = res.data as! UInt

                    var tx: EthereumTransaction
                    if (contractHash == "") {
                        tx = try EthereumTransaction(
                            nonce: EthereumQuantity(quantity: BigUInt(nonce)),
                            gasPrice: EthereumQuantity(quantity: fee),
                            gas: EthereumQuantity(quantity: BigUInt(ethereumGasAmount)),
                            to: EthereumAddress(hex: to, eip55: false),
                            value: EthereumQuantity(quantity: value)
                        )
                    }
                    else {
                        let contractAddress = try EthereumAddress(hex: contractHash, eip55: false)
                        let contract = GenericERC20Contract(address: contractAddress, eth:self.web3.eth)
                        
                        tx = try contract.transfer(to: EthereumAddress(hex: to, eip55: false), value: value).createTransaction(
                            nonce: EthereumQuantity(quantity: BigUInt(nonce)),
                            from: EthereumAddress(hex: address, eip55: false),
                            value: 0,
                            gas: EthereumQuantity(quantity: BigUInt(contractTransferGasAmount)),
                            gasPrice: EthereumQuantity(quantity: fee)
                            )!
                    }
                    
                    DDLogDebug("transaction: \(String(describing: tx))")

                    let newtx: EthereumSignedTransaction = try tx.sign(with: self.privKey!, chainId: self.chainid)
                    
                    DDLogDebug("r: \(newtx.r.hex())")
                    DDLogDebug("s: \(newtx.s.hex())")
                    DDLogDebug("v: \(newtx.v.hex())")

                    DDLogDebug("inputdata: \(tx.data.hex())")

                    url = "\(self.urlServer)/api/v1/sendsignedtransaction"
                    let rawData: Bytes = try! RLPEncoder().encode(newtx.rlp())
                    DDLogDebug("rawDAta: \(String(describing: rawData.toHexString()))")

                    sendRequest(responseObject:VCoinResponse.self, url: url, method: .post,
                                parameters: ["raw": String(describing: rawData.toHexString())])
                        .done {res2 in
                            DDLogDebug("\(res2)")
                            seal.fulfill(res2)
                            }
                        .catch { error2 in
                            seal.reject(error2)
                    }
                }
            }.done { res3 in
//                let resObj = Mapper<ETHSendSignedTransactionResponse>().map(JSONObject: res3.data)
//                let hash: String = (res3.data)! as! String
            
                callback(NRLWalletSDKError.nrlSuccess, res3.data as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback((error as? NRLWalletSDKError)!, 0)
        }
    }
    
    override func signTransaction(contractHash: String, to: String, value: BigUInt, fee: BigUInt, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let address = self.privKey!.address.hex(eip55: false)
        let url = "\(self.urlServer)/api/v1/address/gettransactioncount/\(address)"
        
        firstly {
            sendRequest(responseObject:VCoinResponse.self, url: url)
            }.done { res in
                let nonce: UInt = res.data as! UInt
                
                var tx: EthereumTransaction
                if (contractHash == "0") {
                    tx = try EthereumTransaction(
                        nonce: EthereumQuantity(quantity: BigUInt(nonce)),
                        gasPrice: EthereumQuantity(quantity: BigUInt(fee)),
                        gas: EthereumQuantity(quantity: BigUInt(ethereumGasAmount)),
                        to: EthereumAddress(hex: to, eip55: false),
                        value: EthereumQuantity(quantity: BigUInt(value))
                    )
                }
                else {
                    let contractAddress = try EthereumAddress(hex: contractHash, eip55: false)
                    let contract = GenericERC20Contract(address: contractAddress, eth:self.web3.eth)
                    
                    tx = try contract.transfer(to: EthereumAddress(hex: to, eip55: false), value: BigUInt(value)).createTransaction(
                        nonce: EthereumQuantity(quantity: BigUInt(nonce)),
                        from: EthereumAddress(hex: address, eip55: false),
                        value: 0,
                        gas: EthereumQuantity(quantity: BigUInt(contractTransferGasAmount)),
                        gasPrice: EthereumQuantity(quantity: BigUInt(fee))
                        )!
                }
                
                let newtx: EthereumSignedTransaction = try tx.sign(with: self.privKey!, chainId: self.chainid)
                
                DDLogDebug("r: \(newtx.r.hex())")
                DDLogDebug("s: \(newtx.s.hex())")
                DDLogDebug("v: \(newtx.v.hex())")
                
                DDLogDebug("inputdata: \(tx.data.hex())")
                
                callback(NRLWalletSDKError.nrlSuccess, newtx as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback((error as? NRLWalletSDKError)!, 0)
        }
    }
  
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {
        let transactionSigned = tx as! EthereumSignedTransaction
        let url = "\(self.urlServer)/api/v1/sendsignedtransaction"
        let rawData: Bytes = try! RLPEncoder().encode(transactionSigned.rlp())
        DDLogDebug("rawDAta: \(String(describing: rawData.toHexString()))")
        
        firstly {
                sendRequest(responseObject:VCoinResponse.self, url: url, method: .post,
                            parameters: ["raw": String(describing: rawData.toHexString())])
            }.done { res in
                let resObj = Mapper<ETHSendSignedTransactionResponse>().map(JSONObject: res.data)
                let hash: String = (resObj?.transactionHash)!
                
                callback(NRLWalletSDKError.nrlSuccess, hash as Any)
            }.catch { error in
                DDLogDebug("Failed to send: \(error)")
                callback((error as? NRLWalletSDKError)!, 0)
        }
    }
}
