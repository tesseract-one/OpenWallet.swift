//
//  EthereumKeychainRequestHandler.swift
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

import UIKit
import BigInt


public protocol EthereumKeychainViewProvider {
    typealias ViewResponse<Req: RequestMessageProtocol> = (Swift.Result<Req.Response, OpenWalletError>) -> Void
    
    func accountRequestView(
        req: EthereumAccountKeychainRequest,
        cb: @escaping ViewResponse<EthereumAccountKeychainRequest>
    ) -> UIViewController
    
    func signTransactionView(
        req: EthereumSignTxKeychainRequest,
        cb: @escaping ViewResponse<EthereumSignTxKeychainRequest>
    ) -> UIViewController
    
    func signDataView(
        req: EthereumSignDataKeychainRequest,
        cb: @escaping ViewResponse<EthereumSignDataKeychainRequest>
    ) -> UIViewController
    
    func signTypedDataView(
        req: EthereumSignTypedDataKeychainRequest,
        cb: @escaping ViewResponse<EthereumSignTypedDataKeychainRequest>
    ) -> UIViewController
}


public class EthereumKeychainRequestHandler: RequestHandler {
    public let supportedUTI: Array<String> = ["one.openwallet.keychain.ethereum"]
    
    private let viewProvider: EthereumKeychainViewProvider
    
    public init(viewProvider: EthereumKeychainViewProvider) {
        self.viewProvider = viewProvider
    }
    
    public func viewContoller(for request: String, uti: String, cb: @escaping Completion) throws -> UIViewController {
        let method = try self.method(request, uti: uti)
        switch method {
        case EthereumAccountKeychainRequest.method:
            let req = try Request<EthereumAccountKeychainRequest>(json: request, uti: uti)
            return viewProvider.accountRequestView(req: req.data.request) { result in
                cb(result.map { req.response(data: $0) })
            }
        case EthereumSignTxKeychainRequest.method:
            let req = try Request<EthereumSignTxKeychainRequest>(json: request, uti: uti)
            return viewProvider.signTransactionView(req: req.data.request) { result in
                cb(result.map { req.response(data: $0) })
            }
        case EthereumSignDataKeychainRequest.method:
            let req = try Request<EthereumSignDataKeychainRequest>(json: request, uti: uti)
            return viewProvider.signDataView(req: req.data.request) { result in
                cb(result.map { req.response(data: $0) })
            }
        case EthereumSignTypedDataKeychainRequest.method:
            let req = try Request<EthereumSignTypedDataKeychainRequest>(json: request, uti: uti)
            return viewProvider.signTypedDataView(req: req.data.request) { result in
               cb(result.map { req.response(data: $0) })
            }
        default:
            throw OpenWalletError.notSupported("method - \(method)")
        }
    }
    
    private func method(_ req: String, uti: String) throws -> String {
        return try Request<BaseEthereumMessage>(json: req, uti: uti).data.request.method
    }
}

private struct BaseEthereumMessage: RequestMessageProtocol {
    typealias Response = String
    
    static var method: String = "__base" // Not used
    
    let method: String
}
