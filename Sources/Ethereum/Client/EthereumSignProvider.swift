//
//  EthereumSignProvider.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 3/28/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Ethereum


extension SignProviderError {
    init(error: OpenWalletError) {
        switch error.type {
        case .cancelledByUser:
            self = .cancelled
        case .eth_keychainWrongAccount:
            do {
                self = .accountDoesNotExist(try Address(hex: error.message, eip55: false))
            } catch {
                self = .emptyAccount
            }
        case .eth_keychainTypedDataMalformed, .wrongParameters:
            self = .mandatoryFieldMissing(error.message)
        default:
            self = .internalError(error)
        }
    }
}

extension OpenWallet: SignProvider {
    
    public var canSign: Bool {
        return walletHasAPI(keychain: .Ethereum)
    }
    
    public func eth_accounts(
        networkId: UInt64,
        response: @escaping OpenWallet.Response<Array<Address>>
    ) {
        keychain(net: .Ethereum, request: EthereumAccountKeychainRequest(networkId: networkId)) { result in
            let res: Swift.Result<[Address], SignProviderError> = result
                .mapError { SignProviderError(error: $0) }
                .flatMap { account in
                    do {
                        return .success([try Address(hex: account)])
                    } catch let err {
                        return .failure(.internalError(err))
                    }
                }
            response(res)
        }
    }
    
    public func eth_signTx(
        tx: Transaction, networkId: UInt64, chainId: UInt64,
        response: @escaping OpenWallet.Response<Data>
    ) {
        var request: EthereumSignTxKeychainRequest
        do {
            request = try EthereumSignTxKeychainRequest(
                tx: tx, chainId: chainId, networkId: networkId
            )
        } catch let err {
            response(.failure(SignProviderError(error: err as! OpenWalletError)))
            return
        }
        keychain(
            net: .Ethereum,
            request: request
        ) { result in
            response(result.mapError { SignProviderError(error: $0) })
        }
    }
    
    public func eth_signData(
        account: Address, data: Data, networkId: UInt64,
        response: @escaping OpenWallet.Response<Data>
    ) {
        keychain(
            net: .Ethereum,
            request: EthereumSignDataKeychainRequest(
                account: account.hex(eip55: true),
                data: data,
                networkId: networkId
            )
        ) { result in
            response(result.mapError { SignProviderError(error: $0) })
        }
    }
    
    public func eth_signTypedData(
        account: Address, data: TypedData, networkId: UInt64,
        response: @escaping OpenWallet.Response<Data>
    ) {
        keychain(
            net: .Ethereum,
            request: EthereumSignTypedDataKeychainRequest(
                account: account.hex(eip55: true),
                data: data,
                networkId: networkId
            )
        ) { result in
            response(result.mapError { SignProviderError(error: $0) })
        }
    }
}
