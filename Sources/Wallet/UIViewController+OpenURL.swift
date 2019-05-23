//
//  UIViewController+OpenURL.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 5/23/19.
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

public protocol OpenURLProviderProtocol {
    func open(url: URL) -> Bool
}

extension UIViewController: OpenURLProviderProtocol {
    public func open(url: URL) -> Bool {
        return self.openURL(url)
    }
}

fileprivate extension UIViewController {
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self.next
        while let r = responder {
            if r.responds(to: UIViewController._selector) && !(r is UIViewController)  {
                r.perform(UIViewController._selector, with: url)
                return true
            }
            responder = r.next
        }
        return false
    }
    
    private static let _selector: Selector = #selector(openURL(_:))
}
