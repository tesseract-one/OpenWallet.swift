//
//  Response.swift
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


public protocol SerializableProtocol {
    var uti: String { get }
    
    init(json: String, uti: String) throws
    
    func serialize() throws -> String
}


public protocol ResponseProtocol: SerializableProtocol {}


public struct Response<Request: RequestMessageProtocol>: ResponseProtocol {
    public struct Data<R: Codable>: Codable {
        public let version: Version
        public let id: UInt32
        public let response: R?
        public let error: OpenWalletError?
    }
    
    public let data: Data<Request.Response>
    public let uti: String
    
    public var isError: Bool {
        return data.error != nil
    }
    
    public init(data: Data<Request.Response>, uti: String) {
        self.data = data
        self.uti = uti
    }
    
    public init(json: String, uti: String) throws {
        self.data = try JSONDecoder().decode(Data<Request.Response>.self, from: json.data(using: .utf8)!)
        self.uti = uti
    }
    
    public init(id: UInt32, uti: String, response: Request.Response) {
        self.data = Data(version: .v1, id: id, response: response, error: nil)
        self.uti = uti
    }
    
    public init(id: UInt32, uti: String, error: OpenWalletError) {
        self.data = Data(version: .v1, id: id, response: nil, error: error)
        self.uti = uti
    }
    
    public func serialize() throws -> String {
        let bytes = try JSONEncoder().encode(data)
        return String(data: bytes, encoding: .utf8)!
    }
}
