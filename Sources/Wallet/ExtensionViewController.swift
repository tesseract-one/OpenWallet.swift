//
//  ExtensionViewController.swift
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
#if !COCOAPODS
    @_exported import OpenWalletCore
#endif

public protocol RequestHandler {
    var supportedUTI: Array<String> { get }
    
    typealias Completion = (Swift.Result<ResponseProtocol, OpenWalletError>) -> Void
    
    func viewContoller(
        for request: String,
        uti: String, cb: @escaping Completion
    ) throws -> UIViewController
}

open class ExtensionViewController: UIViewController {
    // parsed request header info
    private var baseRequest: Request<Empty>!
    
    open var handlers: Array<RequestHandler> {
        return []
    }
    
    open func response(_ res: ResponseProtocol) {
        do {
            let reply = NSExtensionItem()
            reply.attachments = [
                NSItemProvider(item: try res.serialize() as NSSecureCoding, typeIdentifier: res.uti)
            ]
            extensionContext!.completeRequest(returningItems: [reply], completionHandler: nil)
        } catch let err {
            extensionContext?.cancelRequest(withError: OpenWalletError.unknownError(err))
        }
    }
    
    open func walletNotInitializedController() -> ExtensionWalletNotInitializedViewController {
        return ExtensionWalletNotInitializedViewController(nibName: nil, bundle: nil)
    }
    
    open func walletIsNotInitialized() {
        let vc = walletNotInitializedController()
        vc.closeCb = { [weak self] in
            if let sself = self {
                sself.response(sself.baseRequest.response(error: .walletIsNotInitialized))
            }
            
        }
        showViewController(vc: vc)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemOpt = extensionContext!.inputItems
            .compactMap{$0 as? NSExtensionItem}
            .compactMap{$0.attachments}
            .flatMap{$0}
            .first
        
        guard let item = itemOpt else {
            extensionContext!.cancelRequest(withError: OpenWalletError.emptyRequest)
            return
        }
        
        guard let requestUTI = item.registeredTypeIdentifiers.first else {
            extensionContext!.cancelRequest(withError: OpenWalletError.emptyRequest)
            return
        }
        
        item.loadItem(forTypeIdentifier: requestUTI, options: nil) { [unowned self] request, error in
            guard let dataStr = request as? String, let base = try? Request<Empty>(json: dataStr, uti: requestUTI) else {
                self.extensionContext!.cancelRequest(withError: OpenWalletError.wrongParameters("message body"))
                return
            }
            
            self.baseRequest = base
            
            let handlerOpt = self.handlers.first{$0.supportedUTI.contains(requestUTI)}
            guard handlerOpt != nil else {
                self.response(base.response(error: .notSupported(requestUTI)))
                return
            }
            
            DispatchQueue.main.async {
                self.onLoaded(data: dataStr, uti: requestUTI)
            }
        }
    }
    
    open func onLoaded(data: String, uti: String) {
        // can be force unwrapped. Checked on viewDidLoad step.
        let handler = handlers.first{$0.supportedUTI.contains(uti)}!
        do {
            let vc = try handler.viewContoller(for: data, uti: uti) { [unowned self] result in
                switch result {
                case .failure(let err): self.error(err)
                case .success(let res): self.response(res)
                }
            }
            showViewController(vc: vc)
        } catch(let err) {
            error(.unknownError(err))
        }
    }
    
    open func error(_ error: OpenWalletError) {
        response(baseRequest.response(error: error))
    }
    
    open func cancelRequest() {
        error(.cancelledByUser)
    }
    
    open func showViewController(vc: UIViewController) {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        view.addSubview(vc.view)
        for child in children {
            child.removeFromParent()
        }
        addChild(vc)
    }
}

private struct Empty: RequestMessageProtocol {
    typealias Response = String
}
