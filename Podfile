# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target ‘ChatFirebase’ do
    
    # Pods for Gifteka
    source 'git@gitlab.com:viczaikin/SwiftExtensions.git'
    source 'git@gitlab.com:viczaikin/GASRequestManagerSwift.git'
    source 'https://github.com/CocoaPods/Specs.git'
    
    pod 'GASSwiftExtensions'
    pod 'GASRequestManagerSwift', :git => 'https://gitlab.com/viczaikin/GASRequestManagerSwift.git', :tag => '0.5.0'
    pod 'GASScrolling', :git => 'https://gitlab.com/viczaikin/GASScrolling.git'
    
    # Image cache & networking
    pod 'Kingfisher', '~> 3.0’
    
    # Resources
    pod 'R.swift', '~> 3.0'

    # GASSwiftExtensions
    pod 'GASSwiftExtensions'
    
    # HUD
    pod 'PKHUD'
    
    # PagerTabStrip
    pod 'XLPagerTabStrip'

    # Firebase
    pod 'Firebase/Storage'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'JSQMessagesViewController'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
