## dependency libraries

### CryptoSwift.framework
>https://github.com/krzyzanowskim/CryptoSwift
>this framework will be installed when run carthage update --platform iOS

### neoutils.framework
>https://github.com/O3Labs/neo-utils
>need setting of bitcode disabled
>need to manually include from O3Labs

# environment
### carthage
* Download latest carthage from https://github.com/Carthage/Carthage/releases
### xcode setting
* Select proper command line tool from Xcode > Preferences > Locations 


# Build Carthage framework

### download dependences
>carthage update --platform iOS

### build project at xcode

### compress framework from building to zip and put it at root directory

### carthage build
>carthage build --no-skip-current

now we can get result at $SOURCEROOT/carthage/Build/iOS
