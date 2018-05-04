//
//  NRLWallet.swift
//  NRLWalletSDK
//
//  Created by David Bala on 5/4/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

public final class NRLWallet {

    private let masterPrivateKey: NRLPrivateKey
    private let network: Network

    public init(seed: Data, network: Network) {
        self.masterPrivateKey = NRLPrivateKey(seed: seed, network: network)
        self.network = network
    }

    // MARK: - Public Methods

    public func generateExternalPrivateKey(at index: UInt32) throws -> NRLPrivateKey {
        return try externalPrivateKey().derived(at: index)
    }

    public func generateInteranlPrivateKey(at index: UInt32) throws -> NRLPrivateKey {
        return try internalPrivateKey().derived(at: index)
    }

    // MARK: - Private Methods

    private func externalPrivateKey() throws -> NRLPrivateKey {
        return try privateKey(change: .external)
    }

    private func internalPrivateKey() throws -> NRLPrivateKey {
        return try privateKey(change: .internal)
    }

    private enum Change: UInt32 {
        case external = 0
        case `internal` = 1
    }

    // m/44'/coin_type'/0'/external
    private func privateKey(change: Change) throws -> NRLPrivateKey {
        return try masterPrivateKey
            .derived(at: 44, hardens: true)
            .derived(at: network.coinType, hardens: true)
            .derived(at: 0, hardens: true)
            .derived(at: change.rawValue)
    }
}
