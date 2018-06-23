//
//  ViewController.swift
//  NRLWalletSDK Example
//
//  Created by David Bala on 5/3/18.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import UIKit
import NRLWalletSDK


//data extension to convert binary data to hex string
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
    // Convert 0 ... 9, a ... f, A ...F to their decimal value,
    // return nil for all other input characters
    fileprivate func decodeNibble(_ u: UInt16) -> UInt8? {
        switch(u) {
        case 0x30 ... 0x39:
            return UInt8(u - 0x30)
        case 0x41 ... 0x46:
            return UInt8(u - 0x41 + 10)
        case 0x61 ... 0x66:
            return UInt8(u - 0x61 + 10)
        default:
            return nil
        }
    }
    
    init?(fromHexEncodedString: String) {
        var str = fromHexEncodedString
        if str.count%2 != 0 {
            // insert 0 to get even number of chars
            str.insert("0", at: str.startIndex)
        }
        
        let utf16 = str.utf16
        self.init(capacity: utf16.count/2)
        
        var i = utf16.startIndex
        while i != str.utf16.endIndex {
            guard let hi = decodeNibble(utf16[i]),
                let lo = decodeNibble(utf16[utf16.index(i, offsetBy: 1, limitedBy: utf16.endIndex)!]) else {
                    return nil
            }
            var value = hi << 4 + lo
            self.append(&value, count: 1)
            i = utf16.index(i, offsetBy: 2, limitedBy: utf16.endIndex)!
        }
    }
}


var coinWallet: NRLWallet?

class ViewController: UIViewController {
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var lbProgress: UILabel!
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var txtTransactions: UITextView!
    
    var mnemonic: [String]?
    
    var blockFromHight: UInt32 = 0
    var blockToHight: UInt32 = 0
    
    @IBAction func OnGetAllTransactions(_ sender: Any) {
        guard let wallet = coinWallet else {
            print("OnGetAllTransactions Error: cannot init wallet!")
            return
        }
        
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
    }
    
    @IBAction func OnConnect(_ sender: Any) {
        let button = sender as! UIButton
        
        guard let wallet = coinWallet else {
            print("OnConnect Error: cannot init wallet!")
            return
        }
        
        if (!(wallet.isConnected())) {
            print("\nStart")
            if (wallet.connectPeers()) {
                button.setTitle("Disconnect", for: UIControlState.normal)
            }
        }
        else {
            print("\nStop")
            if (wallet.disConnectPeers()) {
                button.setTitle("Connect", for: UIControlState.normal)
            }
        }
    }

    
    func setBitcoinWallet() {
        print("\n------------------------- Bitcoin ----------------------------\n")
        // Bitcoin : 0
        
        /* test
         menmonic= "click offer off current alien soon foster wide senior student mystery agree target grace whale puppy slim join wet plug love trophy federal destroy"
         
         address:
         myqAKSukSdtUH4YUregNvfjEWJMk3jTEUj,
         mjnt7mvGW3mZNd6Ao1SamDDezcWrpT8n8r,
         mvb4PXxf77LvtF9ooy1N77tzZSD5bqfFWT,
         n42oeaDttQTJXxVo6wcHFr8AXNe4kifEAm,
         mo89Y9csq3Yy96Vkp8XoZqnKUSFKjedhB7,
         mpaQosi6hUaSPyv4Q5TmHm1BpAQJMWo8Nn,
         mn1qQyyUMAQTK4Qjebof7gSXks7pUFDibq,
         privkeys:
         cS2zeeAtj51W3Pre6bSa8pjcr4nDmFSWQa8ynGzDEbt9xu7w3kBd,
         cPwaYXfxwP7UpEMAczgcub6V5ugK3EVspzmFKuUrQAnqbRD8hzND,
         cUFKu2NJnQxAGEbZwJjsHSzuN1ei2KM4EywtNNg86V9JUVRPfRLq,
         cPTzK5xGh2b6WmbsC2RV4V4G7sGWNtfewv2JcDofysauQrnPMsUK,
         cQErDBqZqbiXqoiTRVHJTkgbX42qqFJmSpoByLLbCRy6xeaFmKEt,
         cRw3wwp8sJiiDbvSbSYKYZ7Zzz7mG5ZayC5aF2oCPTTZCw99KFtU,
         cQHC62RtXrnidk55i19rpWBJGKMXHVG3wWnahxoPMRzVcFtN5aRb,
 
        
        let seed = Data(fromHexEncodedString: "47d8d8898556e5c4fcf042b249ef92160e667046d7ff487392a9e6ca9e1d912b11a7b134baf7a8893c92d1a40731b08d1ef24789128d07101df740ad1ba4a12c")!
        */
        guard let mnemonic = self.mnemonic else {
            print("Error: no mnemonic")
            return
        }
        
        coinWallet = NRLWallet(mnemonic: mnemonic, passphrase: "Test", network: .test(.bitcoin))
        guard let wallet = coinWallet else {
            print("Error: cannot init wallet!")
            return
        }
        
        /*  not use key generation module, instead of it, use bitcoin spv
            bitcoinWallet.generateExternalKeyPair(at: 0)
         
            let privateKey = bitcoinWallet.getWIF()
            let publicKey = bitcoinWallet.getPublicKey()
            let address = bitcoinWallet.getAddress()

            print("\nBitcoinWallet private key = \(privateKey)")
            print("BitcoinWallet public key = \(publicKey)")
            print("BitcoinWallet address = \(address)")
        */

        //notification handlers from spv node events
        NotificationCenter.default.addObserver(self, selector: #selector(WalletDidUpdateBalance(notification:)), name: NSNotification.Name.WSWalletDidUpdateBalance, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidDownloadBlock(notification:)), name: NSNotification.Name.WSPeerGroupDidDownloadBlock, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PeerGroupDidStartDownload(notification:)), name: NSNotification.Name.WSPeerGroupDidStartDownload, object: nil)
        
        /*test date
            let calendar = NSCalendar.current
            var components = DateComponents()
            components.day = 1
            components.month = 4
            components.year = 2018
            let date = calendar.date(from: components)
        */
        let date = Date()
        print("\nCreate Own Wallet")
        if (!wallet.createOwnWallet(created: date, fnew: true)) {
            print("Failed to create wallet")
            return;
        }
        print("\nCreate Peer Group")
        wallet.createPeerGroup()
    }
    
    @objc func WalletDidUpdateBalance(notification: Notification) {
        let walletObj = notification.object as! WSWallet;
        
        guard let wallet = coinWallet else {
            print("WalletDidUpdateBalance Error: cannot init wallet!")
            return
        }
        
        print("Balance: \(walletObj.balance)")
        
        wallet.getWalletBalance() { (err, value) -> () in
            self.lbBalance.text = String(describing: value)
        }
    }
    
    @objc func PeerGroupDidStartDownload(notification: Notification) {
        guard let wallet = coinWallet else {
            print("PeerGroupDidStartDownload Error: cannot init wallet!")
            return
        }
        
        guard let userInfo = notification.userInfo else {
            print("PeerGroupDidStartDownload Error: invalid notification object.")
            return
        }
        
        self.blockFromHight = userInfo[WSPeerGroupDownloadFromHeightKey] as! UInt32
        self.blockToHight = userInfo[WSPeerGroupDownloadToHeightKey] as! UInt32
        
        wallet.getWalletBalance() { (err, value) -> () in
            self.lbBalance.text = String(describing: value)
        }
        self.lbAddress.text = wallet.getReceiveAddress();
        
        var progressed = 0;
        if (self.blockFromHight == self.blockToHight) {
            progressed = 100
        }
        self.lbProgress.text = String(format: "%d/%d       %.2f%%", self.blockFromHight, self.blockToHight, Double(progressed))
    }
    
    @objc func PeerGroupDidDownloadBlock(notification: Notification) {
        let block = notification.userInfo![WSPeerGroupDownloadBlockKey] as! WSStorableBlock
        let currentHeight = block.height() as UInt32;
        let total = self.blockToHight - self.blockFromHight
        let progressed = currentHeight - self.blockFromHight
        
        if (total != 0 && progressed > 0) {
            if (currentHeight <= self.blockToHight) {
                if (currentHeight % 1000 == 0 || currentHeight == self.blockToHight) {
                    self.lbProgress.text = String(format: "%d/%d       %.2f%%", currentHeight, self.blockToHight, Double(progressed) * 100.0 / Double(total))
                }
            }
        }
    }

    
    func generateMneonic() {
        do {
            self.mnemonic = try NRLMnemonic.generateMnemonic(strength: .normal, language: .english)
            let bindedString = self.mnemonic?.joined(separator: " ")
            print("mnemonic = \(String(describing: bindedString))")
        } catch {
            print(error)
        }
    }
    
    func setEthereumWallet() {
        print("\n------------------------- Ethereum ----------------------------\n")

        // Ethereum : 60
        
        guard let mnemonic = self.mnemonic else {
            print("Error: no mnemonic")
            return
        }
        
        coinWallet = NRLWallet(mnemonic: mnemonic, passphrase: "Test", network: .test(.ethereum))

        guard let wallet = coinWallet else {
            print("setEthereumWallet Error: cannot init wallet!")
            return
        }
        
        wallet.createOwnWallet(created: Date(), fnew: true)
    }
    
    func setNeoWallet() {
        print("\n------------------------- NEO ----------------------------\n")
        // NEO : 888

        guard let mnemonic = self.mnemonic else {
            print("Error: no mnemonic")
            return
        }
        coinWallet = NRLWallet(mnemonic: mnemonic, passphrase: "Test", network: .main(.neo))
        
        guard let wallet = coinWallet else {
            print("setNeoWallet Error: cannot init wallet!")
            return
        }
        
        wallet.generateExternalKeyPair(at: 0)
        
        let privateKey = wallet.getWIF()
        let publicKey = wallet.getPublicKey()
        let address = wallet.getAddress()
        
        print("\nNeo private key = \(String(describing: privateKey))")
        print("Neo public key = \(String(describing: publicKey))")
        print("Neo address = \(String(describing: address))")
    }
    
    func setLitecoinWallet() {
        print("\n------------------------- Litecoin ----------------------------\n")
        // Litecoin : 2
        //for test
//        self.mnemonic = ["vivid", "gesture", "series", "lady", "owner", "amused", "sock", "grunt", "hotel", "olive", "carpet", "visual"]
        self.mnemonic = ["nasty", "believe", "cinnamon", "crouch", "snap", "shuffle", "spice", "bleak", "ridge", "planet", "identify", "trumpet"]

        guard let mnemonic = self.mnemonic else {
            print("Error: no mnemonic")
            return
        }
        
        coinWallet = NRLWallet(mnemonic: mnemonic, passphrase: "Test", network: .main(.litecoin))
        
        guard let wallet = coinWallet else {
            print("setLitecoinWallet Error: cannot init wallet!")
            return
        }
        
//        coinWallet?.generateExternalKeyPair(at: 0)
//
//        let privateKey = coinWallet?.getWIF()
//        let publicKey = coinWallet?.getPublicKey()
//        let address = coinWallet?.getAddress()
//
//        print("\nLitecoinWallet private key = \(String(describing: privateKey))")
//        print("LitecoinWallet public key = \(String(describing: publicKey))")
//        print("LitecoinWallet address = \(String(describing: address))")
        
        //notification handlers from spv node events
        NotificationCenter.default.addObserver(self, selector: #selector(On_LTC_WalletDidUpdateBalance(notification:)), name: NSNotification.Name.LTC_WalletDidUpdateBalance, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(On_LTC_PeerGroupDidDownloadBlock(notification:)), name: Notification.Name.LTC_PeerGroupDidDownloadBlock, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(On_LTC_PeerGroupDidStartDownload(notification:)), name: NSNotification.Name.LTC_PeerGroupDidStartDownload, object: nil)
        
        print("\nCreate Own Wallet")
        if (!wallet.createOwnWallet(created: Date(), fnew: false)) {
            print("create wallet failed")
            return
        }
        
        let addresses = wallet.getAddressesOfWallet()
        print("Address: \(String(describing: addresses))")
        print("\nCreate Peer Group")
        wallet.createPeerGroup()
    }
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        return df
    }()
    
    @objc func On_LTC_PeerGroupDidDownloadBlock(notification: Notification) {
        let userinfo = notification.userInfo as! [String: Any]
        
        let progress = userinfo[PeerGroupDownloadBlockProgressKey] as! Double
        let timestamp = userinfo[PeerGroupDownloadBlockTimestampKey] as! UInt32
        
        let txt = dateFormatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
        
        self.lbProgress.text = String(format: "Progress: %.2f %%  \(txt)", (progress * 100))
    }
    
    @objc func On_LTC_WalletDidUpdateBalance(notification: Notification) {
        let userinfo = notification.userInfo as! [String: Any]
        
        let balance = userinfo[WalletBalanceKey] as! UInt64
        
        self.lbBalance.text = String(format: "\(balance)")
    }
    
    @objc func On_LTC_PeerGroupDidStartDownload(notification: Notification) {
        guard let wallet = coinWallet else {
            print("On_LTC_PeerGroupDidStartDownload Error: cannot init wallet!")
            return
        }
        
        wallet.getWalletBalance() { (err, value) -> () in
            self.lbBalance.text = String(describing: value)
        }
        
        DDLogDebug("ReceiveAddress: \(String(describing: wallet.getReceiveAddress()))")
        self.lbAddress.text = wallet.getReceiveAddress();
    }

    
    func setStellarWallet() {
        print("\n------------------------- Stellar ----------------------------\n")
        // Stellar : 148
                
        guard let mnemonic = self.mnemonic else {
            print("Error: no mnemonic")
            return
        }
        
        coinWallet = NRLWallet(mnemonic: mnemonic, passphrase: "Test", network: .main(.stellar))
        
        guard let wallet = coinWallet else {
            print("setStellarWallet Error: cannot init wallet!")
            return
        }
                
        print("\nCreate Own Wallet")
        _ = wallet.createOwnWallet(created: Date(), fnew: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultDebugLevel = DDLogLevel.debug
        DDLog.add(DDTTYLogger.sharedInstance)
        
        generateMneonic()

//        setBitcoinWallet()
//        setEthereumWallet()
//        setLitecoinWallet()
        setStellarWallet()
        

    }
}
