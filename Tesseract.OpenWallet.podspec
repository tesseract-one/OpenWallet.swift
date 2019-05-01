Pod::Spec.new do |s|
  s.name             = 'Tesseract.OpenWallet'
  s.version          = '0.1.0'
  s.summary          = 'Tesseract Open Wallet Protocol implementation for Swift'

  s.description      = <<-DESC
Tesseract Plaftorm Open Wallet Protocol implementation for Swift
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/OpenWallet.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/OpenWallet.swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_one'

  s.ios.deployment_target = '10.0'

  s.module_name = 'OpenWallet'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Core/**/*.swift'
  end

  s.subspec 'Client' do |ss|
    ss.source_files = 'Sources/Client/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Core'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Client'
    ss.dependency 'PromiseKit/CorePromise', '~> 6.8.0'
  end

  s.subspec 'EthereumCore' do |ss|
    ss.source_files = 'Sources/Ethereum/Core/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Core'
    ss.dependency 'Tesseract.EthereumTypes', '~> 0.1'
  end

  s.subspec 'Ethereum' do |ss|
    ss.source_files = 'Sources/Ethereum/Client/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Client'
    ss.dependency 'Tesseract.OpenWallet/EthereumCore'
  end

  s.subspec 'EthereumPromiseKit' do |ss|
    ss.source_files = 'Sources/Ethereum/Client/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Ethereum'
    ss.dependency 'Tesseract.OpenWallet/PromiseKit'
    ss.dependency 'Tesseract.EthereumTypes/PromiseKit', '~> 0.1'
  end

  s.subspec 'Wallet' do |ss|
    ss.source_files = 'Sources/Wallet/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Core'
  end

  s.subspec 'WalletEthereum' do |ss|
    ss.source_files = 'Sources/Ethereum/Wallet/**/*.swift'

    ss.dependency 'Tesseract.OpenWallet/Wallet'
    ss.dependency 'Tesseract.OpenWallet/EthereumCore'
  end

  s.default_subspecs = 'Core', 'Client'
end
