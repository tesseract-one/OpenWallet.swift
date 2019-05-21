//
//  ExtensionViewControllerProtocols.swift
//  OpenWalletWallet
//
//  Created by Yehor Popovych on 5/21/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
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
