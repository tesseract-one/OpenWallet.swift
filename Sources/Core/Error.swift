//
//  Error.swift
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

public struct OpenWalletError: Error, Codable {
    
    public struct _Type: RawRepresentable, Codable, Equatable {
        public typealias RawValue = String
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let notSupported = _Type(rawValue: "NOT_SUPPORTED")
        public static let cancelledByUser = _Type(rawValue: "CANCELLED_BY_USER")
        public static let wrongParameters = _Type(rawValue: "WRONG_PARAMETERS")
        public static let unknownError = _Type(rawValue: "UNKNOWN_ERROR")
    }
    
    let type: _Type
    let message: String
    
    public init(type: _Type, message: String) {
        self.type = type
        self.message = message
    }
    
    public static let cancelledByUser = OpenWalletError(
        type: .cancelledByUser,
        message: "Operation cancelled by user"
    )
    
    public static func notSupported(_ what: String) -> OpenWalletError {
        return OpenWalletError(type: .notSupported, message: "\(what) is not supported")
    }
    
    public static func wrongParameters(_ parameter: String) -> OpenWalletError {
        return OpenWalletError(type: .wrongParameters, message: "Wrong parameters: \(parameter)")
    }
    
    public static func unknownError(_ error: Error) -> OpenWalletError {
        return OpenWalletError(type: .unknownError, message: error.localizedDescription)
    }
    
    public var localizedDescription: String {
        return "Error(type: \(type.rawValue), message: \(message))"
    }
}

extension OpenWalletError {
    public static func decodeError(_ error: Error) -> OpenWalletError {
        return .wrongParameters(error.localizedDescription)
    }
    
    public static func ipcError(_ error: Error) -> OpenWalletError {
        return .unknownError(error)
    }
    
    public static let emptyRootView = OpenWalletError(type: .unknownError, message: "Empty root view")
    public static let emptyRequest = OpenWalletError(type: .wrongParameters, message: "data is empty")
}
