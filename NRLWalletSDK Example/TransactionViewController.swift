//
//  TransactionViewController.swift
//  NRLWalletSDK Example
//
//  Created by David Bala on 06/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import UIKit
import NRLWalletSDK

internal class TransactionViewController: UIViewController {
    @IBOutlet weak var tfTo: UITextField!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var tfFee: UITextField!
    @IBOutlet weak var textTransaction: UITextView!
    
    @IBAction func OnSend() {
        let to = tfTo.text;
        let value = UInt64(tfValue.text!)
        let fee = UInt64(tfFee.text!)
        
        guard let wallet = coinWallet else {
            print("setStellarWallet Error: cannot init wallet!")
            return
        }

        //for stellar, we need to insert double values
        //0xa54722e65fcfff7fd387fe6547a47ebcacdda381
        wallet.sendTransaction(contractHash: "0xa54722e65fcfff7fd387fe6547a47ebcacdda381", to: "0xCaD047badd42445BCE3FED63fa4891718453fE45", value: 200000000000000000, fee: 10000000000) { (err, tx) -> () in
            switch (err) {
            case NRLWalletSDKError.nrlSuccess:
                self.textTransaction.text = "Successfully sent transaction. tx: \(tx)"
            default:
                self.textTransaction.text = "Failed: \(err)"
            }
            
        }
    }
    
    
    @IBAction func onPrev(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
