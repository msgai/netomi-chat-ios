Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "NetomiChatSDK"
  s.version      = "1.1.6"
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
  s.source           = {
    :http => 'https://github.com/msgai/netomi-chat-ios/releases/download/0.0.0/Netomi.xcframework.zip'
  }
  s.static_framework = true
  s.requires_arc = true

  # External dependencies that are used in the SDK
  s.dependency 'AWSIoT'
  
end
