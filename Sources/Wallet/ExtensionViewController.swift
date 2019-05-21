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
    
    open var dataChannel: ExtensionViewControllerDataChannel? = nil
    
    open func response(_ res: ResponseProtocol) {
        dataChannel!.response(viewController: self, response: res)
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
        
        if let _ = extensionContext, dataChannel == nil {
            dataChannel = ExtensionViewContollerShareChannel()
        }
        
        dataChannel!.rawRequest(for: self) { response in
            switch response {
            case .failure(let err):
                self.response(Response<Empty>(uti: OPENWALLET_API_PREFIX, error: err))
            case .success((json: let json, uti: let uti)):
                guard let base = try? Request<Empty>(json: json, uti: uti) else {
                    self.response(Response<Empty>(uti: uti, error: .wrongParameters("message body")))
                    return
                }
                
                self.baseRequest = base
                
                guard let handler = self.handlers.first(where: { $0.supportedUTI.contains(uti) }) else {
                    self.response(base.response(error: .notSupported(uti)))
                    return
                }
                
                DispatchQueue.main.async {
                    self.onLoaded(handler: handler, json: json, uti: uti)
                }
            }
        }
    }
    
    open func onLoaded(handler: RequestHandler, json: String, uti: String) {
        do {
            let vc = try handler.viewContoller(for: json, uti: uti) { [unowned self] result in
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
