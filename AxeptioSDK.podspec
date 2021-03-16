#
# Be sure to run `pod lib lint AxeptioSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AxeptioSDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AxeptioSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Axeptio/AxeptioSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Axeptio' => 'support@axeptio.eu' }
  s.source           = { :git => 'https://github.com/agilitation/axeptio-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.preserve_paths = 'AxeptioSDK/Axeptio.framework'
  s.vendored_frameworks = 'AxeptioSDK/Axeptio.framework'
  
  s.frameworks = 'UIKit'
  s.dependency 'KeychainSwift'
  s.dependency 'Alamofire', '~> 5.2'
  s.dependency 'Kingfisher'
end
