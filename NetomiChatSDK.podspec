Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "NetomiChatSDK"
  s.version      = "1.1.2"
  s.summary      = "Netomi Chat SDK"
  s.description  = <<-DESC
  "The Netomi Chat SDK is a software development kit that enables developers to integrate Netomi Chat interface into their applications, allowing for AI-powered virtual agents that automate customer interactions across chat and messaging channels. Leveraging Netomi Agentic OS, it streamlines customer support by providing instant responses, automating routine tasks, and seamlessly escalating complex queries to human agents when needed."
                   DESC
  s.homepage     = "https://github.com/msgai/netomi-chat-ios.git"
  s.license      = "Netomi"
  s.author             = { "Netomi" => "sdk-admin@netomi.com" }
  s.platform     = :ios, "15.0"
  s.ios.deployment_target = "15.0"
  s.swift_version = '5.0'
  s.source       = { :git => "https://github.com/msgai/netomi-chat-ios.git", :tag => "#{s.version}" }
  
  # Load source files from framework & paths settings.
  s.source_files  = "Sources/**/*.{swift,h, xib}"
  s.static_framework = true
  s.requires_arc = true
  s.vendored_frameworks =      [
        "Sources/Netomi.xcframework",
        "Sources/ExternalFrameworks.xcframework",
        ]
  
  # External dependencies that are used in the SDK
  s.dependency 'AWSIoT'
  
end
