Pod::Spec.new do |s|
  s.name         = "NetomiChatSDK"
  s.version      = "1.1.7"
  s.summary      = "Netomi Chat SDK"
  s.description  = <<-DESC
    The Netomi Chat SDK is a software development kit that enables developers to integrate Netomi Chat interface into their applications, allowing for AI-powered virtual agents that automate customer interactions across chat and messaging channels. Leveraging Netomi Agentic OS, it streamlines customer support by providing instant responses, automating routine tasks, and seamlessly escalating complex queries to human agents when needed.
  DESC

  s.homepage     = "https://github.com/msgai/netomi-chat-ios"
  s.license      = "Netomi"
  s.author       = { "Netomi" => "sdk-admin@netomi.com" }
  s.platform     = :ios, "15.0"
  s.swift_version = '5.0'
  s.source       = {
    :http => "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.1.7/Netomi.xcframework.zip"
  }

  s.vendored_frameworks = "Netomi.xcframework"
  s.static_framework = true
  s.requires_arc = true

  s.dependency 'AWSIoT'
end
