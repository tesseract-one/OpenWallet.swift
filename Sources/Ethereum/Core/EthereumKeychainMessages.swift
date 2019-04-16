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

@_exported import EthereumBase


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
    
    public init(tx: Transaction, chainId: UInt64, networkId: UInt64) {
        self.init(
            nonce: "0x" + String(tx.nonce, radix: 16),
            from: tx.from.hex(eip55: true),
            to: tx.to?.hex(eip55: true),
            gas: "0x" + String(tx.gas, radix: 16),
            gasPrice: "0x" + String(tx.gasPrice, radix: 16),
            value: "0x" + String(tx.value, radix: 16),
            data: tx.data,
            chainId: "0x" + String(BigUInt(chainId), radix: 16),
            networkId: networkId
        )
    }
    
    public var transaction: Transaction {
        return Transaction(
            nonce: BigUInt(remove0x(nonce), radix: 16)!,
            gasPrice: BigUInt(remove0x(gasPrice), radix: 16)!,
            gas: BigUInt(remove0x(gas), radix: 16)!,
            from: try! Address(hex: from),
            to: to != nil ? try! Address(hex: to!) : nil,
            value: BigUInt(remove0x(value), radix: 16)!,
            data: data
        )
    }
    
    public var chainIdInt: UInt64 {
        return UInt64(BigUInt(remove0x(chainId), radix: 16)!)
    }
    
    private func remove0x(_ str: String) -> String {
        return String(str.suffix(from: str.index(str.startIndex, offsetBy: 2)))
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
