//
//  OpenWallet.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 3/6/19.
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
import UIKit


public class OpenWallet {
    private var requestCounter: UInt32
    private let lock = NSLock()
    private var requestQueue: Array<UIActivityViewController> = []
    
    public let networks: Set<Network>
    
    public init(networks: [Network]) {
        self.requestCounter = 0
        self.networks = Set(networks)
    }
    
    public func request<R: RequestMessageProtocol>(
        _ request: Request<R>,
        response: @escaping (Result<R.Response, OpenWalletError>) -> Void
    ) {
        let vc = UIActivityViewController(
            activityItems: [request.activityItemSource],
            applicationActivities: nil
        )
        
        // All system types
        var types: [UIActivity.ActivityType] = [
            .addToReadingList, .airDrop, .assignToContact, .copyToPasteboard,
            .copyToPasteboard, .mail, .message, .openInIBooks,
            .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter,
            .postToVimeo, .postToWeibo, .print, .saveToCameraRoll
        ]
        if #available(iOS 11.0, *) {
            types.append(.markupAsPDF)
        }
        vc.excludedActivityTypes = types
        
        vc.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            defer {
                DispatchQueue.main.async {
                    self.requestQueue.removeFirst()
                    guard let rootView = self.rootViewController else {
                        self.requestQueue.removeAll()
                        return
                    }
                    if self.requestQueue.count > 0 {
                        rootView.present(self.requestQueue[0], animated: true, completion: nil)
                    }
                }
            }
            if let error = error {
                if let opwErr = error as? OpenWalletError {
                    response(.failure(opwErr))
                } else {
                    response(.failure(.ipcError(error)))
                }
                return
            }
            guard completed else {
                response(.failure(.cancelledByUser))
                return
            }
            OpenWallet.response(req: request, items: returnedItems, response: response)
        }
        
        DispatchQueue.main.async {
            guard let rootView = self.rootViewController else {
                response(.failure(.emptyRootView))
                return
            }
            self.requestQueue.append(vc)
            
            if self.requestQueue.count == 1 {
                rootView.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    public var requestId: UInt32 {
        lock.lock()
        defer { lock.unlock() }
        requestCounter += 1
        return requestCounter
    }
}

extension OpenWallet {
    private var rootViewController: UIViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController
    }
    
    private static func response<R: RequestMessageProtocol>(
        req: Request<R>, items: [Any]?,
        response: @escaping (Result<R.Response, OpenWalletError>) -> Void
    ) {
        let attachments = items?.compactMap {$0 as? NSExtensionItem}.compactMap{$0.attachments}.flatMap{$0}
        guard let item = attachments?.first else {
            response(.failure(.wrongParameters("empty response")))
            return
        }
        item.loadItem(forTypeIdentifier: req.uti, options: nil) { result, error in
            if let error = error {
                response(.failure(.ipcError(error)))
            } else if let data = result as? String {
                do {
                    let res = try req.parseResponse(json: data)
                    if res.isError {
                        response(.failure(res.data.error!))
                    } else {
                        response(.success(res.data.response!))
                    }
                } catch(let err) {
                    response(.failure(.decodeError(err)))
                }
            } else {
                if let result = result {
                    response(.failure(.wrongParameters("bad response: \(result)")))
                } else {
                    response(.failure(.wrongParameters("bad response: null")))
                }
            }
        }
    }
}

//extension OpenWallet {
//    public var distributedAPI: dAPI {
//        let dapi = dAPI()
//        dapi.signProvider = self
//        return dapi
//    }
//}
