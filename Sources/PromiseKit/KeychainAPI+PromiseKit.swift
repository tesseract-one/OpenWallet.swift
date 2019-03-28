//
//  KeychainAPI+PromiseKit.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 3/29/19.
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
import PromiseKit

extension OpenWallet {
    public func keychain<R: KeychainRequestMessageProtocol>(net: Network, request: R) -> Promise<R.Response> {
        return Promise { resolver in
            let req = KeychainRequest(network: net, id: requestId, request: request)
            return self.request(req, response: resolver.fromResult)
        }
        
    }
}

extension Resolver {
    func fromResult<Err: Error>(_ swiftResult: Swift.Result<T, Err>) {
        switch swiftResult {
        case .success(let val): fulfill(val)
        case .failure(let err): reject(err)
        }
    }
}
