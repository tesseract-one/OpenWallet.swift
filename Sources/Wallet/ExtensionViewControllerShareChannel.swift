//
//  ExtensionViewControllerShare.swift
//  OpenWalletWallet-iOS
//
//  Created by Yehor Popovych on 5/21/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation
#if !COCOAPODS
    @_exported import OpenWalletCore
#endif


public struct ExtensionViewContollerShareChannel: ExtensionViewControllerDataChannel {
    
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
