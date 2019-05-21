//
//  ExtensionViewControllerURLChannel.swift
//  OpenWalletWallet-iOS
//
//  Created by Yehor Popovych on 5/21/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation
#if !COCOAPODS
    @_exported import OpenWalletCore
#endif

public protocol ExtensionViewControllerURLChannelDelegate: class {
    func extensionViewControllerFinished(vc: ExtensionViewController, channel: ExtensionViewControllerURLChannel, opened: Bool)
}

public struct ExtensionViewControllerURLChannel: ExtensionViewControllerDataChannel {
    
    public let uti: String
    public let messageBase64: String
    public let callback: URL
    
    public weak var delegate: ExtensionViewControllerURLChannelDelegate?
    
    public init(request: URL) throws {
        guard let components = URLComponents(url: request, resolvingAgainstBaseURL: true) else {
            throw OpenWalletError.wrongParameters("can't parse URL options")
        }
        
        let cbUrl = components.queryItems?
            .first{ $0.name == "callback" }?.value
            .flatMap{URL(string: $0)}
        
        guard let callback = cbUrl else {
            throw OpenWalletError.wrongParameters("callback")
        }
        
        let msgOpt = components.queryItems?
            .first{ $0.name == "message" }?.value
        
        guard let message = msgOpt else {
            throw OpenWalletError.emptyRequest
        }
        
        guard let scheme = components.scheme else {
            throw OpenWalletError.wrongParameters("scheme")
        }
        
        let api = scheme
            .replacingOccurrences(of: "\(OPENWALLET_URL_API_PREFIX)-", with: "")
            .replacingOccurrences(of: "-", with: ".")
        
        self.messageBase64 = message
        self.callback = callback
        self.uti = "\(OPENWALLET_API_PREFIX).\(api)"
    }
    
    private func sendResponse(vc: ExtensionViewController, data: Data) {
        let cb = self.callback.absoluteString + "#\(OPENWALLET_URL_API_PREFIX)-\(data.base64EncodedString())"
        // Can be force unwrapped. callback is url, and we are adding proper anchor (base64 is valid anchor symbols)
        let opened = vc.openURL(URL(string: cb)!)
        delegate?.extensionViewControllerFinished(vc: vc, channel: self, opened: opened)
    }
    
    public func walletIsNotInitialized(viewController: ExtensionViewController) {
        let res = Response<Empty>(uti: uti, error: .walletIsNotInitialized)
        response(viewController: viewController, response: res)
    }
    
    public func response(viewController: ExtensionViewController, response: ResponseProtocol) {
        do {
            let string = try response.serialize()
            guard let data = string.data(using: .utf8) else {
                throw OpenWalletError.wrongParameters("can't encode utf8")
            }
            sendResponse(vc: viewController, data: data)
        } catch let err {
            let errorResponse: Response<Empty>
            switch err {
            case let error as OpenWalletError:
                errorResponse = Response(uti: response.uti, error: error)
            default:
                errorResponse = Response(uti: response.uti, error: .unknownError(err))
            }
            
            // Error response always can be converted to data
            sendResponse(
                vc: viewController,
                data: try! errorResponse.serialize().data(using: .utf8)!
            )
        }
    }
    
    public func rawRequest(for viewController: ExtensionViewController, response: @escaping (Result<(json: String, uti: String), OpenWalletError>) -> Void) {
        DispatchQueue.global().async {
            guard let data = Data(base64Encoded: self.messageBase64) else {
                response(.failure(.wrongParameters("can't decode base64")))
                return
            }
            guard let json = String(data: data, encoding: .utf8) else {
                response(.failure(.wrongParameters("can't read message utf8")))
                return
            }
            response(.success((json: json, uti: self.uti)))
        }
    }
}
