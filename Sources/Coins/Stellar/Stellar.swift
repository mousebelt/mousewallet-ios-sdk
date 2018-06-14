//
//  Ethereum.swift
//  NRLWalletSDK
//
//  Created by David Bala on 16/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation
import ed25519C

class NRLStellar : NRLCoin{
    var pubkeyData: Data?
    var keyPair: KeyPair?
    
    func accountId(bytes: [UInt8]) -> String {
        var versionByte = VersionByte.accountId.rawValue
        let versionByteData = Data(bytes: &versionByte, count: MemoryLayout.size(ofValue: versionByte))
        let payload = NSMutableData(data: versionByteData)
        payload.append(Data(bytes: bytes))
        let checksumedData = (payload as Data).crc16Data()
        
        return checksumedData.base32EncodedString
    }
    
    func secret(seed: Seed) -> String {
        return seed.secret
    }
    
    init(mnemonic: [String], seed: Data, fTest: Bool) {
        var network: NRLNetwork = .main(.stellar)
        if (fTest) {
            network = .test(.ethereum)
        }
        
        let cointype = network.coinType
        
        super.init(mnemonic: mnemonic,
                   seed: seed,
                   network: network,
                   coinType: cointype,
                   seedKey: "ed25519 seed",
                   curve: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
    }
    
    /*
     Now that you have a seed and public key, you can create an account. In order to prevent people from making a huge number of unnecessary accounts, each account must have a minimum balance of 1 lumen (lumens are the built-in currency of the Stellar network).[2] Since you don’t yet have any lumens, though, you can’t pay for an account. In the real world, you’ll usually pay an exchange that sells lumens in order to create a new account.[3] On Stellar’s test network, however, you can ask Friendbot, our friendly robot with a very fat wallet, to create an account for you.
     */
    
    func generatePublickey(seed: Seed) {
        
        self.keyPair = KeyPair(seed: seed)
        
        self.pubkeyData = Data(bytes: (self.keyPair?.publicKey.bytes)!)
        self.wif = secret(seed: seed);
        self.address = accountId(bytes: (self.keyPair?.publicKey.bytes)!);
    }
    
    override func generateExternalKeyPair(at index: UInt32) throws {
        
        self.masterPrivateKey = NRLPrivateKey(seed: self.seed, privkey: generateMasterKey(), coin: self)
        self.pathPrivateKey = try path_derive(index: index)
        
        let stellarSeed = try! Seed(bytes: (self.pathPrivateKey?.raw.bytes)!)
        generatePublickey(seed: stellarSeed)
    }
    
    override func generateInternalKeyPair(at index: UInt32) throws {
        try generateExternalKeyPair(at: index)
    }
    
    // m/44'/coin_type'/0'/external
    private func path_derive(index: UInt32) throws -> NRLPrivateKey {
        return masterPrivateKey!
            .derived_Ed25519(at: 44)
            .derived_Ed25519(at: coinType)
            .derived_Ed25519(at: index)
    }
    
    override func getPublicKey() -> Data {
        return self.pubkeyData!
    }
    
    override func createOwnWallet(created: Date, fnew: Bool) {
        do {
            try generateExternalKeyPair(at: 0)
            
            let privateKey = getPrivateKeyStr()
            let publicKey = getPublicKey()
            let address = getAddressStr()
            
            print("\nstellar private key = \(String(describing: privateKey))")
            print("stellar public key = \(String(describing: publicKey))")
            print("stellar address = \(String(describing: address))")
        } catch {
            print(error)
        }

//        // create keypair with the seed of your already existing account.
//        // replace the seed with your own.
//        let sourceAccountKeyPair = try KeyPair(secretSeed:"SDXEJKRXYLTV344KWCRJ4PXXXJVXKGK3UGESRWBWLDEWYO4S5OQ6VQ6I")
//
//        // generate a random keypair representing the new account to be created.
//        let destinationKeyPair = try KeyPair.generateRandomKeyPair()
//        print("Destination account Id: " + destinationKeyPair.accountId)
//        print("Destination secret seed: " + destinationKeyPair.secretSeed)
//
//        // load the source account from horizon to be sure that we have the current sequence number.
//        sdk.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
//            switch response {
//            case .success(let accountResponse): // source account successfully loaded.
//                do {
//                    // build a create account operation.
//                    let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: 2.0)
//
//                    // build a transaction that contains the create account operation.
//                    et transaction = try Transaction(sourceAccount: accountResponse,
//                                                     operations: [createAccount],
//                                                     memo: Memo.none,
//                                                     timeBounds:nil)
//
//                    // sign the transaction.
//                    try transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
//
//                    // submit the transaction to the stellar network.
//                    try sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
//                        switch response {
//                        case .success(_):
//                            print("Account successfully created.")
//                        case .failure(let error):
//                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Create account", horizonRequestError: error)
//                        }
//                    }
//                } catch {
//                    // ...
//                }
//            case .failure(let error): // error loading account details
//                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
//            }
//        }

    }
    override func createPeerGroup() {}
    override func connectPeers() -> Bool {return false}
    override func disConnectPeers() -> Bool {return false}
    override func startSyncing() -> Bool {return false}
    override func stopSyncing() -> Bool {return false}
    override func isConnected() -> Bool {return false}
    override func isDownloading() -> Bool {return false}
    override func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: String) -> ()) {}
    override func getAddressesOfWallet() -> NSArray? {return nil}
    override func getPrivKeysOfWallet() -> NSArray? {return nil}
    override func getPubKeysOfWallet() -> NSArray? {return nil}
    override func getReceiveAddress() -> String? {return ""}
    override func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ()) {}
    //transaction
    override func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    override func signTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}
    override func sendSignTransaction(tx: Any, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) {}

}
