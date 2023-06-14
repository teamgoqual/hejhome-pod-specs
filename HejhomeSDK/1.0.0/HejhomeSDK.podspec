#
# Be sure to run `pod lib lint HejhomeSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HejhomeSDK'
  s.version          = '1.0.0'
  s.summary          = 'HejhomeSDK.'
  s.swift_versions   = '4.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://bitbucket.org/goqual-workspace/hejhome-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '김다솜' => 'dskim0704@goqual.com' }
  s.source           = { :git => 'https://bitbucket.org/goqual-workspace/hejhome-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'HejhomeSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HejhomeSDK' => ['HejhomeSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.frameworks = 'Foundation'
  
  s.subspec 'Base' do |base|
    base.source_files = 'HejhomeSDK/Classes/Base/**/*'
    base.dependency 'ThingSmartHomeKit','~> 5.0.0'
    base.dependency 'CryptoSwift', '~> 1.3.8'
  end
  
  s.subspec 'Camera' do |camera|
    camera.source_files = 'HejhomeSDK/Classes/Camera/**/*'
    camera.dependency 'ThingSmartHomeKit','~> 5.0.0'
    camera.dependency 'ThingSmartCameraKit','~> 5.6.0'
    camera.dependency 'ThingCameraUIKit','~> 5.0.0'
  end
  
end
