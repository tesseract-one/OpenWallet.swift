//
//  EthereumKeychainMessages.swift
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
import Serializable
import BigInt
#if !COCOAPODS
    import OpenWalletCore
#endif

@_exported import Ethereum




public protocol EthereumRequestMessageProtocol: KeychainRequestMessageProtocol {
    var networkId: UInt64 { get }
}

public struct EthereumAccountKeychainRequest: EthereumRequestMessageProtocol {
    public typealias Response = String
    
    public static let method: String = "get_account"
    public let method: String = EthereumAccountKeychainRequest.method
    
    public let networkId: UInt64
    
    public init(networkId: UInt64) {
        self.networkId = networkId
    }
}

public struct EthereumSignTxKeychainRequest: EthereumRequestMessageProtocol {
    public typealias Response = Data
    
    public static let method: String = "sign_transaction"
    public let method: String = EthereumSignTxKeychainRequest.method
    
    public let networkId: UInt64
    
    // From TX
    public let nonce: String
    public let from: String
    public let to: String?
    public let gas: String
    public let gasPrice: String
    public let value: String
    public let data: Data
    
    public let chainId: String
    
    public init(nonce: String, from: String, to: String? = nil,
                gas: String, gasPrice: String, value: String,
                data: Data, chainId: String, networkId: UInt64) {
        self.nonce = nonce
        self.from = from
        self.to = to
        self.gas = gas
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
        self.chainId = chainId
        self.networkId = networkId
    }
    
    public init(tx: Transaction, chainId: UInt64, networkId: UInt64) throws {
        guard let nonce = tx.nonce else { throw OpenWalletError.wrongParameters("nonce") }
        guard let gasPrice = tx.gasPrice else { throw OpenWalletError.wrongParameters("nonce") }
        guard let gasLimit = tx.gas else { throw OpenWalletError.wrongParameters("gas") }
        guard let from = tx.from else { throw OpenWalletError.wrongParameters("from") }
        let value = tx.value ?? 0
        self.init(
            nonce:  nonce.hex,
            from: from.hex(eip55: true),
            to: tx.to?.hex(eip55: true),
            gas: gasLimit.hex,
            gasPrice: gasPrice.hex,
            value: value.hex,
            data: tx.data.data,
            chainId: Quantity(integerLiteral: chainId).hex,
            networkId: networkId
        )
    }
    
    public func transaction() throws -> Transaction {
        return Transaction(
            nonce: try Quantity(hex: nonce),
            gasPrice: try Quantity(hex: gasPrice),
            gas: try Quantity(hex: gas),
            from: try Address(hex: from),
            to: to != nil ? try Address(hex: to!) : nil,
            value: try Quantity(hex: value),
            data: EthData(data)
        )
    }
    
    public func chainIdInt() throws -> UInt64 {
        return try UInt64(Quantity(hex: chainId).quantity)
    }
}

public struct EthereumSignTypedDataKeychainRequest: EthereumRequestMessageProtocol {
    public typealias Response = Data
    
    public static let method: String = "sign_typed_data"
    public let method: String = EthereumSignTypedDataKeychainRequest.method
    
    public let networkId: UInt64
    
    public let account: String
    
    public let types: Dictionary<String, Array<TypedData._Type>>
    public let primaryType: String
    public let domain: TypedData.Domain
    public let message: Dictionary<String, SerializableValue>
    
    public init(account: String, data: TypedData, networkId: UInt64) {
        self.networkId = networkId
        self.types = data.types
        self.primaryType = data.primaryType
        self.domain = data.domain
        self.message = data.message
        self.account = account
    }
    
    var typedData: TypedData {
        return TypedData(
            primaryType: primaryType,
            types: types,
            domain: domain,
            message: message
        )
    }
}

public struct EthereumSignDataKeychainRequest: EthereumRequestMessageProtocol {
    public typealias Response = Data
    
    public static let method: String = "sign"
    public let method: String = EthereumSignDataKeychainRequest.method
    
    public let networkId: UInt64
    
    public let account: String
    public let data: Data
    
    public init(account: String, data: Data, networkId: UInt64) {
        self.account = account
        self.data = data
        self.networkId = networkId
    }
}
