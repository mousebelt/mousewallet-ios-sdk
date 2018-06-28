# dependency libraries

## Carthage

>this framework will be installed when run carthage update --platform iOS

* github "krzyzanowskim/CryptoSwift"
* github "attaswift/BigInt" ~> 3.0
* github "Boilertalk/Web3.swift"
* github "Alamofire/Alamofire" ~> 4.7
* github "Hearst-DD/ObjectMapper" ~> 3.2
* github "SwiftyJSON/SwiftyJSON" ~> 4.0

* these sources are derived from Web3.swift
>github "mxcl/PromiseKit"
>github "Boilertalk/secp256k1.swift"

## framework
### neoutils.framework
>https://github.com/O3Labs/neo-utils
>need setting of bitcode disabled
>need to manually include from O3Labs
>to build neo-utils, need to install go and go-mobile


## included sources

### web3.swift

>https://github.com/Boilertalk/Web3.swift

### CocoaLumberjack (Libraries)

can be downloaded from BitcoinSPV pod. or 

>https://github.com/CocoaLumberjack/CocoaLumberjack

### secp256k1
>https://github.com/bitcoin-core/secp256k1
>need to add in Libraries manually

### BitcoinSPV (Libraries)
>https://github.com/keeshux/BitcoinSPV/
>need to add in Libraries manually

### openssl

can be downloaded from BitcoinSPV pod. or 

to libs of libssl and libcrypto should be explicitly included as linked library of NRLWalletSDK

>https://github.com/openssl/openssl
>need to add in Libraries manually

### loafwallet-core (Libraries)
>https://github.com/litecoin-foundation/loafwallet-ios
>only included loafwallet-core

### stellar-ios-mac-sdk
>https://github.com/Soneso/stellar-ios-mac-sdk
>only included part of this sdk, so need to update for each files


# environment
### carthage
* Download latest carthage from https://github.com/Carthage/Carthage/releases
### xcode setting
* Select proper command line tool from Xcode > Preferences > Locations 


# Build Carthage framework

## build

### download dependences
>carthage update --platform iOS

### build project at xcode

### compress framework from building to zip and put it at root directory

### carthage build
>carthage build --no-skip-current
>carthage archive NRLWalletSDK

>git push   ---> this carthage can be used as global carthage file

## key / address test
### bitcoin, litecoin, ethereum
>https://iancoleman.io/bip39/

### neo
>https://coranos.github.io/neo/ledger-nano-s/recovery/

### stellar
>https://github.com/stellar/go/releases/  stellar-hd-wallet

## transaction test

### ethereum
* http://etherscan.io/
* http://ropsten.etherscan.io/

### bitcoin
* faucet: https://testnet.manu.backend.hamburg/faucet
* https://testnet.blockchain.info/

### litecoin
* https://live.blockcypher.com/ltc

### neo
* https://neotracker.io/

### stellar
* https://stellarchain.io/


