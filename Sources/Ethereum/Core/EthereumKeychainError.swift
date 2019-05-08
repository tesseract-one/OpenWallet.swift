//
//  EthereumKeychainError.swift
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


public extension OpenWalletError._Type {
    
    static let eth_keychainWrongAccount = OpenWalletError._Type(rawValue: "WRONG_ACCOUNT")
    
    
    static let eth_keychainTypedDataMalformed = OpenWalletError._Type(
        rawValue: "TYPED_DATA_MALFORMED"
    )
}


extension OpenWalletError {
    
    public static func eth_keychainWrongAccount(_ account: String) -> OpenWalletError {
        return OpenWalletError(type: .eth_keychainWrongAccount, message: account)
    }
    
    public static func eth_keychainTypedDataMalformed(_ error: Error) -> OpenWalletError {
        return OpenWalletError(
            type: .eth_keychainTypedDataMalformed,
            message: "Typed data malformed: \(error.localizedDescription)"
        )
    }
}
