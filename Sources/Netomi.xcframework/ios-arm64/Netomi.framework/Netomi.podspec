Pod::Spec.new do |s|
    s.name         = "Netomi"
    s.version      = "1.0.0"
    s.summary      = "Netomi Chat Widget"
    s.description  = "Netomi Chat Widget"
    
    s.homepage     = "http://gitlab.appinvent.in/netomi/ios/ncw-sdk.git"
    s.license      = "Appinventiv"
    s.author       = { "Akash Gupta" => "akash.gupta1@appinventiv.com" }
    s.platform     = :ios, "13.0"
    s.ios.deployment_target = "13.0"
    s.swift_version = '5.0'
    s.source       = { :git => "http://gitlab.appinvent.in/netomi/ios/ncw-sdk.git", :tag => "#{s.version}" }
    
    # Source files
    s.source_files = "Netomi/Library/**/*.{swift,h}"
    
    # Include only essential resources
    s.resource_bundle = {
        'Netomi' => [
        "Netomi/Library/**/*.xib",
        "Netomi/Library/**/*.storyboard",
        "Netomi/Library/**/*.plist",
        "Netomi/Library/Resources/JSONFiles/**/*.json",
        "Netomi/Library/**/*.xcassets"
        ]
    }
    
    s.static_framework = true
    s.requires_arc = true
    
    s.preserve_paths = 'bin/*'
    s.xcconfig            = {
        'LD_RUNPATH_SEARCH_PATHS' => '@loader_path/../Frameworks'
    }
    
    # External dependencies that are used in the SDK
    s.dependency 'AWSIoT'
#    s.dependency 'lottie-ios'
end
