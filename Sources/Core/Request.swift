//
//  Request.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 3/7/19.
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


public enum Version: String, Codable {
    case v1 = "1.0"
}

public protocol RequestMessageProtocol: Codable {
    associatedtype Response: Codable
}


open class Request<Request: RequestMessageProtocol>: SerializableProtocol {
    public struct Data<R: Codable>: Codable {
        public let version: Version
        public let id: UInt32
        public let request: R
    }
    
    public let data: Data<Request>
    public let uti: String
    
    public init(data: Data<Request>, uti: String) {
        self.data = data
        self.uti = uti
    }
    
    public init(id: UInt32, request: Request, uti: String) {
        data = Data(version: .v1, id: id, request: request)
        self.uti = uti
    }
    
    required public init(json: String, uti: String) throws {
        self.data = try JSONDecoder().decode(Data<Request>.self, from: json.data(using: .utf8)!)
        self.uti = uti
    }
    
    public func serialize() throws -> String {
        let bytes = try JSONEncoder().encode(data)
        return String(data: bytes, encoding: .utf8)!
    }
    
    public func response(data: Request.Response) -> Response<Request> {
        return Response(id: self.data.id, uti: uti, response: data)
    }
    
    public func response(error: OpenWalletError) -> Response<Request> {
        return Response(id: data.id, uti: uti, error: error)
    }
    
    public func parseResponse(json: String) throws -> Response<Request> {
        return try Response<Request>(json: json, uti: uti)
    }
}
