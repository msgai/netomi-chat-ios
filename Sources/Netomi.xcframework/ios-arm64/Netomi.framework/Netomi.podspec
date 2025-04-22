Pod::Spec.new do |s|
    s.name         = "Netomi"
    s.version      = "1.1.2"
    s.summary      = "Netomi Chat Widget"
    s.description  = "Netomi Chat Widget"
    
    s.homepage     = "https://github.com/msgai/Chat-widget-sdk-ios.git"
    s.license      = "Netomi"
    s.author       = { "Akash Gupta" => "akash.gupta1@appinventiv.com" }
    s.platform     = :ios, "13.0"
    s.ios.deployment_target = "13.0"
    s.swift_version = '5.0'
    s.source       = { :git => "https://github.com/msgai/Chat-widget-sdk-ios.git", :tag => "#{s.version}" }
    
    # Source files
    s.source_files = "Netomi/Library/**/*.{swift,h,xib}"
    
    # Include only essential resources
    s.resource_bundle = {
        'Netomi' => [
        "Netomi/Library/**/*.xib",
        "Netomi/Library/**/*.storyboard",
        "Netomi/Library/Resources/**/*.plist",
        "Netomi/Library/Resources/JSONFiles/**/*.json",
        "Netomi/Library/Resources/Sounds/**/*.wav",
        "Netomi/Library/**/*.xcassets",
        "Netomi/Library/Resources/Localization/**/*.strings",
        ]
    }
    
    # Importing External Frameworks
    s.static_framework = true
    s.requires_arc = true
    s.vendored_frameworks = "Netomi/Library/ExternalFrameworks/ExternalFrameworks.xcframework"
    
    # External dependencies that are used in the SDK
    s.dependency 'AWSIoT'
end
