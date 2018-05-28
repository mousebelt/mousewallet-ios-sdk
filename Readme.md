## dependency libraries

### CryptoSwift.framework
>https://github.com/krzyzanowskim/CryptoSwift
>this framework will be installed when run carthage update --platform iOS

### neoutils.framework
>https://github.com/O3Labs/neo-utils
>need setting of bitcode disabled
>need to manually include from O3Labs
>to build neo-utils, need to install go and go-mobile

### BitcoinSPV
>https://github.com/keeshux/BitcoinSPV/
>need to add in Libraries manually

### secp256k1
>https://github.com/bitcoin-core/secp256k1
>need to add in Libraries manually

### openssl
>https://github.com/openssl/openssl
>need to add in Libraries manually

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

now we can get result at $SOURCEROOT/carthage/Build/iOS


## test
### bitcoin, litecoin, ethereum
>https://iancoleman.io/bip39/

### neo
>https://coranos.github.io/neo/ledger-nano-s/recovery/

### stellar
>https://github.com/stellar/go/releases/  stellar-hd-wallet


