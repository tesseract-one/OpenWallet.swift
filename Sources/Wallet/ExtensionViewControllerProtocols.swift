//
//  ExtensionViewControllerProtocols.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 5/21/19.
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
#if !COCOAPODS
    @_exported import OpenWalletCore
#endif


public protocol ExtensionViewControllerDelegate {
    func response(
        viewController: ExtensionViewController,
        response: ResponseProtocol
    )
}

public protocol ExtensionViewControllerRequestSource {
    func rawRequest(
        for viewController: ExtensionViewController,
        response: @escaping (Swift.Result<(json: String, uti: String), OpenWalletError>) -> Void
    )
}

public typealias ExtensionViewControllerDataChannel = ExtensionViewControllerDelegate & ExtensionViewControllerRequestSource

internal struct Empty: RequestMessageProtocol {
    typealias Response = String
}
