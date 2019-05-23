//
//  ExtensionViewControllerShare.swift
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


public struct ExtensionViewContollerShareChannel: ExtensionViewControllerDataChannel {
    
    public init() {}
    
    public func response(viewController: ExtensionViewController, response: ResponseProtocol) {
        do {
            let reply = NSExtensionItem()
            reply.attachments = [
                NSItemProvider(
                    item: try response.serialize() as NSSecureCoding,
                    typeIdentifier: response.uti
                )
            ]
            viewController.extensionContext!.completeRequest(returningItems: [reply], completionHandler: nil)
        } catch let err {
            viewController.extensionContext!.cancelRequest(withError: OpenWalletError.unknownError(err))
        }
    }
    
    public func rawRequest(for viewController: ExtensionViewController, response: @escaping (Result<(json: String, uti: String), OpenWalletError>) -> Void) {
        let itemOpt = viewController.extensionContext!.inputItems
            .compactMap{$0 as? NSExtensionItem}
            .compactMap{$0.attachments}
            .flatMap{$0}
            .first
        
        guard let item = itemOpt else {
            response(.failure(.emptyRequest))
            return
        }
        
        guard let requestUTI = item.registeredTypeIdentifiers.first else {
            response(.failure(.emptyRequest))
            return
        }
        
        item.loadItem(forTypeIdentifier: requestUTI, options: nil) { request, error in
            guard let dataStr = request as? String else {
                response(.failure(.wrongParameters("message body type")))
                return
            }
            response(.success((json: dataStr, uti: requestUTI)))
        }
    }
}
