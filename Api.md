# NRLWalletSDK
## NRLMnemonic
SDK provides Mnemonic as a class to handle mnemonic/seed related apis.
This class has no constructor and only provides 

* **Strength**
  Mnemonic provided by SDK has strength, which set the count of generated mnemonic strings.

  ```
    case normal = 128
    case hight = 256
  ```
  > `.normal` means 12 words length mnemonic
  > `.normal` means 24 words length mnemonic

* **Languages**
  Mnemonic provides following languages as enum value:

  ```
    case english
    case chinese
    case korean
    case spanish
    case french
    case italian
    case japanese
  ```

* **error**
While using Mnemonic, can get following error values

  ```
    case invalidStrength        //strength parameter error
    case unableToGetRandomData  //failed to generate random data
    case unableToCreateSeedData //failed to create seed data
    case invalidMnemonic        //invalid mnemonic
  ```

### generateMnemonic
Generate random words mnemonic.

* **Prototype**
> func generateMnemonic(strength: Strength = .normal, language: NRLMnemonicLanguage = .english) throws -> [String]

* **Parameter**
**strength** : Strength of menonic.
**language** : language for menonic.

* **Success Response**
Returns mnemonic as array of words.
* **Failed Case**
**NRLMnemonicError.invalidStrength** : strength parameter error
**NRLMnemonicError.unableToGetRandomData**: failed generate random data
* **Example**
```
do {
let mnemonic = try NRLMnemonic.generateMnemonic(strength: .normal, language: .english)
let bindedString = self.mnemonic?.joined(separator: " ")
print("mnemonic: \(String(describing: bindedString))")
} catch {
print(error)
}
```
* **output**
```
mnemonic: Optional("speed snack party portion owner size strong essay stand hedgehog evidence second")
```

### mnemonicToSeed
Create Seed data from mnemonic.

* **Prototype**
> func mnemonicToSeed(from mnemonic: [String], withPassphrase: String = "") throws -> Data

* **Parameter**
  **mnemonic** : menonic representd as word array.
  **withPassphrase** : passphrase which will be used to create seed.

* **Success Response**
  Returns Seed data created.
* **Failed Case**
  **NRLMnemonicError.invalidMnemonic** 
  **NRLMnemonicError.unableToGetRandomData**
 * **Example**
 ```
 do {
    var seed = try NRLMnemonic.mnemonicToSeed(from: mnemonic, withPassphrase: passphrase)
    DDLogDebug("\nseed: \(String(describing: seed?.hexEncodedString()))")
 
 } catch let error {
    DDLogDebug("Cannot generate seed: \(error)")
 }
 ```
 * **output**
 ```
 seed: Optional("7a593b7e8f4bb956430dcf6d7d582abca90930571065ea7533841b21de7a650474fe0c7cae4e80b79d92dfb5be60d271a98609cf9876fa88c54e476e5efd3fd1")
 ```
  
  ## NRLWallet
  Wallet class provides apis for manage wallets for several coins.
  
  * **NRLNetwork**
  Represents coin network value which is used BIP44) ( `https://github.com/satoshilabs/slips/blob/master/slip-0044.md` ).

  ```
      case .main(.ethereum):
      case .test(.ethereum):
      case .main(.bitcoin):
      case .test(.bitcoin):
      case .main(.litecoin):
      case .test(.litecoin):
      case .main(.neo):
      case .test(.neo):
      case .main(.stellar):
      case .test(.stellar):
  ``` 
  * **NRLWalletSDKError**
  error code for Wallet sdk
  ```
  enum NRLWalletSDKError: Error {
  public enum RequestError: Error {
  case invalidURL
  case invalidParameters(Any)
  case unexpected(Any)
  }
  
  public enum ResponseError: Error {
  case jsonrpcError(JSONRPCError)
  case connectionError(Error)
  case unacceptableStatusCode(Int)
  case noContentProvided
  case resourceMissing(Any)
  case unexpected(Any)
  }
  
  public enum CryptoError: Error {
  case failed(Any)
  case failedToSign
  case failedToCreateTransaction
  case keyDerivateionFailed
  }
  
  public enum SyncError: Error {
  case failedToConnect
  }
  
  public enum TransactionError: Error {
  case parameterError
  case publishError
  case transactionFailed(Any)
  }
  
  public enum AccountError: Error {
  case keyError
  case addressError
  case seqnumError
  case notCreated
  case nowallet
  case failed(Any)
  }
  
  case nrlSuccess
  case requestError(RequestError)
  case responseError(ResponseError)
  case cryptoError(CryptoError)
  case syncError(SyncError)
  case transactionError(TransactionError)
  case accountError(AccountError)
  case malformedData
  }
 ``` 
  
  ### Constructor
  initialize wallet and coin objects that are included in NRLWallet.
  * **Prototype**
  > init(mnemonic: [String], passphrase: String, network: NRLNetwork, symbol: String = "")
  
  * **Parameter**
    **mnemonic** : menonic representd as word array.
    **passphrase** : passphrase which will be used to create seed.
    **network** : coin network for wallet.
    **symbol**: sub token symbol
    
* **Example**
```
let coinWallet = NRLWallet(mnemonic: mnemonic, passphrase: "", network: .main(.neo), symbol: "NEO")
```
    
  ### createOwnWallet
  Create wallets for all coins, which means to create private key and address for each coins.
  
  * **Prototype**
  > func createOwnWallet(created: Date, fnew: Bool) -> Bool
  
  * **Parameter**
  **created** : created date of wallet. Peer sync will start from blocks of this date. Default is date of NRLWallet service started.
  **fnew** : true: remove whole stored data and create wallet newly. false: load wallet from stored data.
  
  * **Response**
    returns true if success, false if failed.
  * **Example**
  ```
  if (wallet.createOwnWallet(created: Date(), fnew: true)) {
  }
  ```
  
  ### getWalletBalance
  get balance of wallet.
  
  * **Prototype**
 > func getWalletBalance(callback:@escaping (_ err: NRLWalletSDKError, _ value: Any) -> ())
  
  * **Parameter**
  **callback** : callback for response.
  
  * **Success Response**
  **err**: NRLWalletSDKError.nrlSuccess
  **value**:
      * **Bitcoin**
      Balance string of Double value of bitcoin balance. unit is BTC
      * **Ethereum**
      Ethereum and sub token balances as ETHGetBalanceResponse object. balance unit is ETH
      ```
      class ETHGetBalanceMap: Mappable, Equatable {
        public var balance: String?
        public var symbol: String?
      }
      
      class ETHGetBalanceResponse: Mappable {
        public var balances: [ETHGetBalanceMap]?
      }
     ``` 
      * **Litecoin**
      Balance of UInt64 value of LTC balance. unit is LTC
      * **NEO**
      Neo and sub token balances as NeoGetBalanceResponse object.
      ```
      class NeoTokenMapp: Mappable {
          public var name:String?     //token name
          public var symbol:String?   //token symbol
          public var asset:String?    //token address
          public var type:String?
      }
      class NeoAssetMap: Mappable {
          public var asset:String?
          public var value:Double?
          public var symbol:String?
          public var token:NeoTokenMapp?
      }
      public class NeoGetBalanceResponse: Mappable, Equatable {
          public var address:String?
          public var n_tx: UInt?
          public var balance:[NeoAssetMap]?
      }
     ```
      * **Stellar**
      Stellar and sub token balances as StellarAccountResponse object.
      ```
      class StellarAccountFlagsResponse: Mappable {
          /// Requires the issuing account to give other accounts permission before they can hold the issuing account’s credit.
          var authRequired:Bool?
          /// Allows the issuing account to revoke its credit held by other accounts.
          var authRevocable:Bool?
          /// If this is set then none of the authorization flags can be set and the account can never be deleted.
          var authImmutable:Bool?
      }
      public class StellarAccountBalanceResponse: Mappable {
          /// Balance for the specified asset.
          var balance:String?
          /// Maximum number of asset amount this account can hold.
          var limit:String?
          /// The asset type. Possible values: native, credit_alphanum4, credit_alphanum12
          /// See also Constants.AssetType
          var assetType:String?
          /// The asset code e.g., USD or BTC.
          var assetCode:String?
          /// The account id of the account that created the asset.
          var assetIssuer:String?
      }
     ```
      
  * **Failed Case**
NRLWalletSDKError
  * **Example**
  ```
  wallet.getWalletBalance() { (err, balance) -> () in
      switch (err) {
      case NRLWalletSDKError.nrlSuccess:
          print("balanceobj: \(String(describing: balance))")
          let balanceobj = balance as! NeoGetBalanceResponse
      
          let value1 = balanceobj.balance![0].value;
          print("balance: \(String(describing: value1))")
      default:
      self.lbBalance.text = "Failed: \(err)"
  }
  ```
  
  ### getAddressesOfWallet
  Get all addresses created from mnemonic.
  
  * **Prototype**
  > func getAddressesOfWallet() -> NSArray?
  
  * **Parameter**
  
  * **Success Response**
  Returns NSArray of addresses.
  * **Failed Case**
  Returns NSArray()
  * **Example**
  ```
  let addresses = wallet.getAddressesOfWallet()
  print("Address: \(String(describing: addresses))")
  ```
  * **Output**
  ```
  (
  1QCyzqfSaochwUN9UL72ATfWB4rvWvWEZi,
  1DRpqshpNTfThtoGo33SgFDw5Fiqd1YfQk,
  1JDiFPjsK2yfFDKA2HNJcWKAgZ4oaxeXhJ,
  1CbUFUbjrrjgw1GYE47JoogqUW1q1ErgNu,
  13GKT8iFi6k3L9xff1FTAkQrrdrW3Vmw7e,
  12BEJmJsrgz24eBRfSomhRNCNuTBCHEdtj,
  ...
  )
 ```
  ### getPrivKeysOfWallet
  Create private keys created from mnemonic.
  
  * **Prototype**
  > func getPrivKeysOfWallet() -> NSArray?
  
  * **Parameter**
  
  * **Success Response**
  Returns NSArray of addresses.
  for Litecoin returns NSArray()
  * **Failed Case**
  Returns NSArray()
  * **Example**
  ```
  let keys = wallet.getPrivKeysOfWallet()
  print("keys: \(String(describing: keys))")
  ```


  
  ### getReceiveAddress
  Returns an address which will be recieve coins.
  
  * **Prototype**
  > func getReceiveAddress() -> String
  
  * **Parameter**
  
  * **Success Response**
  Returns Address string
  * **Failed Case**
  Returns ""
  * **Example**
  ```
  let address = wallet.getReceiveAddress()
  print("Recieve address: \(address)")
  ```
  * **output**
  ```
  Receive address: 1QCyzqfSaochwUN9UL72ATfWB4rvWvWEZi
  ```
  
  ### getAccountTransactions
  Get transaction list of current wallet.
  
  * **Prototype**
  > func getAccountTransactions(offset: Int, count: Int, order: UInt, callback:@escaping (_ err: NRLWalletSDKError , _ tx: Any ) -> ())
  
  * **Parameter**
  **offset** : offset from the start of transaction list. This will be start of return values.
  **count** : count of transactions to receive.
  **order** : asend(0) or desend(1) of result.
  
  * **Success Response**
  **err**: NRLWalletSDKError.nrlSuccess
  **value**:
  * **Bitcoin**
  Transacctions as array of WSTransaction objects
  ```
  @protocol WSTransaction <NSObject>
  
  - (uint32_t)version;
  - (NSOrderedSet *)inputs;   // id<WSTransactionInput>
  - (NSOrderedSet *)outputs;  // WSTransactionOutput
  - (uint32_t)lockTime;
  
  - (WSHash256 *)txId;
  - (BOOL)isCoinbase;
  
  @end
 ```
  * **Ethereum**
  Transactions as ETHGetTransactionsResponse
  ```
  class ETHTxDetailResponse: Mappable, Equatable {
      public var blockHash: String?
      public var blockNumber: UInt?
      public var from: String?
      public var to: String?
      public var gas: UInt?
      public var gasPrice: String?
      public var hash: String?
      public var input: String?
      public var nonce: UInt?
      public var transactionIndex: UInt?
      public var value: UInt?
      public var v: String?
      public var r: String?
      public var s: String?
  }
  public class ETHGetTransactionsResponse: Mappable, Equatable {
      public var total: UInt?
      public var result: [ETHTxDetailResponse]?
    }
 ``` 
  * **Litecoin**
  Transactions as array of BRTransaction
  ```
  public struct BRTransaction {
  
      public var txHash: UInt256
      
      public var version: UInt32
      
      public var inputs: UnsafeMutablePointer<BRTxInput>!
      
      public var inCount: Int
      
      public var outputs: UnsafeMutablePointer<BRTxOutput>!
      
      public var outCount: Int
      
      public var lockTime: UInt32
      
      public var blockHeight: UInt32
      
      public var timestamp: UInt32 // time interval since unix epoch
 }
 ```
  * **NEO**
  Transactions as NeoTransactionsMap
  ```
  public class NeoTransactionDetailMap: Mappable {
      public var transactionID: String?
      public var size: Int64?
      public var type: String?
      public var version: Int64?
      // var attributes: [] //Need to handle this, not really sure what kind of objects it can give bakc
      public var valueIns: [NeoValueInMap]?
      public var systemFee: String?
      public var networkFee: String?
      
      public var valueOuts: [NeoValueOutMap]?
      public var scripts: [NeoScriptMap]?
      public var blockhash: String?
      public var confirmations: UInt64?
      public var blocktime: UInt64?
  }
  class NeoTransactionsMap: Mappable {
      public var total: String?
      public var result: [NeoTransactionDetailMap]?
  }
  ```
  * **Stellar**
  Transactions as StellarGetTransactionsResponse.
  
  ```
  class StellarTxDetailResponse: Mappable, Equatable {
      var id: String?
      var paging_token: String?
      var hash: String?
      var ledger: UInt?
      var created_at: String?
      var source_account: String?
      var source_account_sequence: String?
      var fee_paid: UInt?
      var operation_count: UInt?
      var envelope_xdr: String?
      var result_xdr: String?
      var result_meta_xdr: String?
      var fee_meta_xdr: String?
      var signatures: [String]?
  }
  public class StellarGetTransactionsResponse: Mappable {
      var next: String?
      var prev: String?
      var result: [StellarTxDetailResponse]?
  }
  class StellarSendSignedTransactionResponse: Mappable, Equatable {
      var result_meta_xdr: String?
      var result_xdr: String?
      var hash: String?
      var ledger: String?
      var envelope_xdr: String?
  }
 ```

  * **Failed Case**
  **err**: NRLWalletSDKError
  **value**: nil 
  * **Example**
  ```
  wallet.getAccountTransactions(offset: 0, count: 10, order: 0){ (err, tx) -> () in
  switch (err) {
  case NRLWalletSDKError.nrlSuccess:
      //for ethereum tx is ETHGetTransactionsResponse mapping object and can get any field
      var strTransactions = String(describing: tx)
      
      strTransactions = strTransactions.replacingOccurrences(of: "\\n", with: "\n")
      strTransactions = strTransactions.replacingOccurrences(of: "\\t", with: "\t")
      
      print("transactions: \(strTransactions)")
      self.txtTransactions.text = strTransactions
  case NRLWalletSDKError.responseError(.unexpected(let error)):
      self.txtTransactions.text = "Server request error: \(error)"
  case NRLWalletSDKError.responseError(.connectionError(let error)):
      self.txtTransactions.text = "Server connection error: \(error)"
  default:
    self.txtTransactions.text = "Failed: \(String(describing: err))"
  }
  }
  ```
  
  ### sendTransaction
  Send signed transaction of send.
  
  * **Prototype**
  > func sendTransaction(contractHash: String = "", to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) 
  > func sendTransaction(to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) 
  > func sendTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ())
  > func sendTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ())
  * **Parameter**
  **contractHash** : sub token address. for example erc20 token address.
  **to** : address to send.
  **value** : amount to send.
  **fee** : fee for transaction.
  
  * **function 1** : Ethereum  ~ value and fee is Wei(1E18) unit
  * **function 2** : Bitcoin, Litecoin  ~ value and fee is satoshi and litoshi(1E8) unit
  * **function 3**: Neo ~ value and fee is Neo unit
  * **function 4**: Stellar ~ value and fee is XLM unit
  
  stellar, litecoin, neo: fee has no meaning
  
  * **Success Response**
  **err**: NRLWalletSDKError.nrlSuccess
  **value**: transaction hash
  
  * **Failed Case**
  **err**: NRLWalletSDKError
  **value**: nil 
  * **Example**
  ```
  wallet.sendTransaction(contractHash: "0xa54722e65fcfff7fd387fe6547a47ebcacdda381", to: "0xCaD047badd42445BCE3FED63fa4891718453fE45", value: 200000000000000000, fee: 10000000000) { (err, tx) -> () in
  switch (err) {
  case NRLWalletSDKError.nrlSuccess:
    self.textTransaction.text = "Successfully sent transaction. tx: \(tx)"
  default:
    self.textTransaction.text = "Failed: \(err)"
  }
  
  }
  ```

### signTransaction
get raw data of signed transaction.

* **Prototype**
> func signTransaction(contractHash: String = "0", to: String, value: UInt64, fee: UInt64, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ()) 
> func signTransaction(asset: AssetId, to: String, value: Decimal, fee: Decimal, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ())
> func signTransaction(to: String, value: Double, fee: Double, callback:@escaping (_ err: NRLWalletSDKError, _ tx:Any) -> ())
* **Parameter**
**contractHash** : sub token address. for example erc20 token address.
**to** : address to send.
**value** : amount to send.
**fee** : fee for transaction.

* **function 1** : Bitcoin, Ethereum, Litecoin  ~ value and fee is wei unit
* **function 2**: Neo ~ value and fee is Neo unit
* **function 3**: Stellar ~ value and fee is XLM unit

stellar, litecoin, neo: fee has no meaning

* **Success Response**
**err**: NRLWalletSDKError.nrlSuccess
**value**: Data

  for bitcoin it returns WSSignedTransaction object
  for ethereum it returns EthereumSignedTransaction object
  for litecoin it returns BRTxRef = UnsafeMutablePointer<BRTransaction>
  for stellar and neo returns string of raw data

* **Failed Case**
**err**: NRLWalletSDKError
**value**: nil 
* **Example**
```
wallet.signTransaction(contractHash: "0xa54722e65fcfff7fd387fe6547a47ebcacdda381", to: "0xCaD047badd42445BCE3FED63fa4891718453fE45", value: 200000000000000000, fee: 10000000000) { (err, tx) -> () in
switch (err) {
case NRLWalletSDKError.nrlSuccess:
    self.textTransaction.text = "Successfully signed transaction. tx: \(tx)"
default:
    self.textTransaction.text = "Failed: \(err)"
}

}
```
