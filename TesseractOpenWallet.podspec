Pod::Spec.new do |s|
  s.name             = 'TesseractOpenWallet'
  s.version          = '0.0.1'
  s.summary          = 'Tesseract Open Wallet SDK for iOS'

  s.description      = <<-DESC
iOS Swift SDK for Open Wallet protocol
                       DESC

  s.homepage         = 'https://github.com/tesseract.1/ios-openwallet-sdk'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract.1/ios-openwallet-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_io'

  s.ios.deployment_target = '10.0'

  s.module_name = 'OpenWallet'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Core/**/*.swift'
  end

  s.subspec 'Client' do |ss|
    ss.source_files = 'Sources/Client/**/*.swift'

    ss.dependency 'TesseractOpenWallet/Core'
  end

  s.subspec 'EthereumCore' do |ss|
    ss.source_files = 'Sources/Ethereum/Core/**/*.swift'

    ss.dependency 'TesseractOpenWallet/Core'
    ss.dependency 'TesseractEthereumBase', '~> 0.0.1'
  end

  s.subspec 'Ethereum' do |ss|
    ss.source_files = 'Sources/Ethereum/Client/**/*.swift'

    ss.dependency 'TesseractOpenWallet/Client'
    ss.dependency 'TesseractOpenWallet/EthereumCore'
  end

  s.subspec 'Wallet' do |ss|
    ss.source_files = 'Sources/Wallet/**/*.swift'

    ss.dependency 'TesseractOpenWallet/Core'
  end

  s.subspec 'WalletEthereum' do |ss|
    ss.source_files = 'Sources/Ethereum/**/*.swift'

    ss.dependency 'TesseractOpenWallet/Wallet'
    ss.dependency 'TesseractOpenWallet/EthereumCore'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'TesseractWallet/Core'
    ss.dependency 'PromiseKit', '~> 6.8.0'
  end

  s.default_subspecs = 'Core', 'Client'
end
