Pod::Spec.new do |s|
  s.name         = "NetomiChatSDK"
  s.version = "1.18.1"
  s.summary      = "Netomi Chat SDK"
  s.description  = <<-DESC
    The Netomi Chat SDK is a software development kit that enables developers to integrate Netomi Chat interface into their applications, allowing for AI-powered virtual agents that automate customer interactions across chat and messaging channels. Leveraging Netomi Agentic OS, it streamlines customer support by providing instant responses, automating routine tasks, and seamlessly escalating complex queries to human agents when needed.
  DESC

  s.homepage     = "https://github.com/msgai/netomi-chat-ios"
  s.license = {
    :type => 'Netomi 1.0',
    :text => <<-LICENSE
      Licensed under the Netomi, Inc., Version 1.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at:

      https://www.netomi.com/about-us/contact

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.
    LICENSE
  }
  s.author       = { "Netomi" => "support@netomi.com" }
  s.platform     = :ios, "16.0"
  s.swift_version = '5.9'
  s.source       = {
    :http => "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.1/Netomi.xcframework.zip"
  }

  s.vendored_frameworks = [
    'Netomi.xcframework'
  ]

  s.static_framework = true
  s.requires_arc = true

  s.dependency 'AWSIoT'
  s.dependency 'MicrosoftCognitiveServicesSpeech-iOS', '~> 1.47.0'
  
end
