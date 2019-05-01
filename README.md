# OpenWallet.swift

[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](https://raw.githubusercontent.com/tesseract-one/OpenWallet.swift/master/LICENSE)
[![Build Status](https://travis-ci.com/tesseract-one/OpenWallet.swift.svg?branch=master)](https://travis-ci.com/tesseract-one/OpenWallet.swift)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/OpenWallet.swift.svg)](https://github.com/tesseract-one/OpenWallet.swift/releases)
[![CocoaPods version](https://img.shields.io/cocoapods/v/Tesseract.OpenWallet.svg)](https://cocoapods.org/pods/Tesseract.OpenWallet)
![Platform iOS](https://img.shields.io/badge/platform-iOS-orange.svg)

## Open Wallet Protocol implementation for Swift based client platforms

## Goals

This library implements Open Wallet Protocol for platforms with native Swift support.

It allows applications to interact with Blockchain wallets with implemented Open Wallet protocol.

## Features

* Can check is Wallet installed and supports needed API.
* Can interact with installed Wallet.
* Can be used by Wallets for OpenWallet implementation.

## Implemented APIs

* Ethereum
  * Keychain API

## Getting started

### Web3

__This is not a Web3 implementation.__

We have a Web3 implementation too: [EthereumWeb3.swift](https://github.com/tesseract-one/EthereumWeb3.swift)

### Installation

#### Ethereum

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'Tesseract.OpenWallet/Ethereum'

# Uncomment this line if you want to enable PromiseKit extensions
# pod 'Tesseract.OpenWallet/EthereumPromiseKit'
```

Then run `pod install`.

### Examples

#### Ethereum

##### Get user accounts (public addresses)

```swift
import OpenWallet

let openWallet = OpenWallet(networks: [.Ethereum])

// Mainnnet Network ID = 1
openWallet.eth_accounts(networkId: 1) { response in
    switch response {
    case .success(let accounts): print("Accounts:", accounts)
    case .failure(let error): print("Error:", error)
    }
}
```

##### Sign data

```swift
import OpenWallet

let data = "some string".data(using: .utf8)!
let address = try! Address(hex: "0x0000000000000000000000000000000000000000")

let openWallet = OpenWallet(networks: [.Ethereum])

// Mainnnet Network ID = 1
openWallet.eth_signData(account: address, data: data, networkId: 1) { response in
    switch response {
    case .success(let signature): print("Signature:", signature)
    case .failure(let error): print("Error:", error)
    }
}
```

## Wallet

### Installation

#### Ethereum

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'Tesseract.OpenWallet/WalletEthereum'
```

Then run `pod install`.

### Usage

Inherit your Extension main View Controller from `ExtensionViewController` class from this library.

## Author

 - [Tesseract Systems, Inc.](mailto:info@tesseract.one)
   ([@tesseract_one](https://twitter.com/tesseract_one))

## License

`OpenWallet.swift` is available under the Apache 2.0 license. See [the LICENSE file](https://raw.githubusercontent.com/tesseract-one/OpenWallet.swift/master/LICENSE) for more information.
