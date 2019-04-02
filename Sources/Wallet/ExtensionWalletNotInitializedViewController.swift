//
//  ExtensionWalletNotInitializedViewController.swift
//  OpenWallet
//
//  Created by Yehor Popovych on 4/2/19.
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

open class ExtensionWalletNotInitializedViewController: UIViewController {
    open let walletUrlScheme: String = ""
    
    @IBAction
    open func openWallet() {
        let url = URL(string: walletUrlScheme)!
        
        var responder: UIResponder? = self
        while let r = responder {
            if r.responds(to: selector) {
                r.perform(selector, with: url)
                break
            }
            responder = r.next
        }
    }
    
    let selector: Selector = #selector(NSNull.open(_:options:completionHandler:))
}

private extension NSNull {
    @objc func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
        // Workaround for compiler
    }
}

