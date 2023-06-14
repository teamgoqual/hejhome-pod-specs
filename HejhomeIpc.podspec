#
# Be sure to run `pod lib lint HejhomeIpc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HejhomeIpc'
  s.version          = '1.1.6'
  s.summary          = 'Hejhome Camera SDK'
  s.swift_versions   = '4.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://bitbucket.org/goqual-workspace/hejhome-camera-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '김다솜' => 'dskim0704@goqual.com' }
  s.source           = { :git => 'https://bitbucket.org/goqual-workspace/hejhome-camera-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'HejhomeIpc/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HejhomeIpc' => ['HejhomeIpc/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'

  s.dependency 'ThingSmartHomeKit','~> 5.0.0'
  s.dependency 'ThingSmartCameraKit','~> 5.6.0'
  s.dependency 'ThingCameraUIKit','~> 5.0.0'
  s.dependency 'CryptoSwift', '~> 1.3.8'
  
  s.static_framework = true
end
