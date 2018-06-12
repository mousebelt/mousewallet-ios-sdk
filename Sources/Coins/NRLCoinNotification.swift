//
//  NRLCoinNotification.swift
//  NRLWalletSDK
//
//  Created by David Bala on 12/06/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    
    public static let LTC_PeerGroupDidConnect: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidConnectNotification")
    public static let LTC_PeerGroupDidDisconnect: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidDisconnectNotification")
    public static let LTC_PeerGroupPeerDidConnect: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupPeerDidConnectNotification")
    public static let LTC_PeerGroupPeerDidDisconnect: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupPeerDidDisconnectNotification")
    public static let LTC_PeerGroupDidStartDownload: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidStartDownloadNotification")
    public static let LTC_PeerGroupDidFinishDownload: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidFinishDownloadNotification")
    public static let LTC_PeerGroupDidFailDownload: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidFailDownloadNotification")
    public static let LTC_PeerGroupDidDownloadBlock: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidDownloadBlockNotification")
    public static let LTC_PeerGroupWillRescan: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupWillRescanNotification")
    public static let LTC_PeerGroupDidRelayTransaction: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidRelayTransactionNotification")
    public static let LTC_PeerGroupDidReorganize: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidReorganizeNotification")
    public static let LTC_PeerGroupDidReject: NSNotification.Name = NSNotification.Name(rawValue: "LTC_PeerGroupDidRejectNotification")
    
    public static let LTC_WalletDidRegisterTransaction: NSNotification.Name = NSNotification.Name(rawValue: "LTC_WalletDidRegisterTransactionNotification")
    public static let LTC_WalletDidUnregisterTransaction: NSNotification.Name = NSNotification.Name(rawValue: "LTC_WalletDidUnregisterTransactionNotification")
    public static let LTC_WalletDidUpdateBalance: NSNotification.Name = NSNotification.Name(rawValue: "LTC_WalletDidUpdateBalanceNotification")
    public static let LTC_WalletDidUpdateAddresses: NSNotification.Name = NSNotification.Name(rawValue: "LTC_WalletDidUpdateAddressesNotification")
    public static let LTC_WalletDidUpdateTransactionsMetadata: NSNotification.Name = NSNotification.Name(rawValue: "LTC_WalletDidUpdateTransactionsMetadataNotification")
}

public let PeerGroupPeerHostKey                              = "PeerHost"
public let PeerGroupReachedMaxConnectionsKey                 = "ReachedMaxConnections"
public let PeerGroupRelayTransactionKey                      = "Transaction"
public let PeerGroupRelayIsPublishedKey                      = "IsPublished"
public let PeerGroupReorganizeOldBlocksKey                   = "OldBlocks"
public let PeerGroupReorganizeNewBlocksKey                   = "NewBlocks"
public let PeerGroupRejectCodeKey                            = "Code"
public let PeerGroupRejectReasonKey                          = "Reason"
public let PeerGroupRejectTransactionIdKey                   = "TransactionId"
public let PeerGroupRejectBlockIdKey                         = "BlockId"
public let PeerGroupRejectWasPendingKey                      = "WasPending"

public let PeerGroupDownloadFromHeightKey                    = "FromHeight"
public let PeerGroupDownloadToHeightKey                      = "ToHeight"
public let PeerGroupDownloadBlockKey                         = "Block"

public let PeerGroupDownloadBlockProgressKey                 = "Progress"
public let PeerGroupDownloadBlockTimestampKey                = "Timestamp"

public let WalletBalanceKey                                  = "Balance"
public let WalletTransactionKey                              = "Transaction"
public let WalletTransactionsMetadataKey                     = "TransactionMetadata"

public let PeerGroupErrorKey                                 = "Error"
