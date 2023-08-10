
Pod::Spec.new do |s|
  s.name             = 'HejhomeSDKBase'
  s.version          = '1.3.4'
  s.summary          = 'HejhomeSDKBase'
  s.swift_versions   = '4.0'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://bitbucket.org/goqual-workspace/hejhome-pod-specs'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '김다솜' => 'dskim0704@goqual.com' }
  s.source           = { :git => 'https://bitbucket.org/goqual-workspace/hejhome-base-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Base/Classes/**/*'
  
  s.static_framework = true
  s.info_plist = {
          'CFBundleIdentifier' => 'org.cocoapods.HejhomeSDKBase'
      }
  
  s.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
      }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.frameworks = 'Foundation'
  
  s.dependency 'ThingSmartActivatorKit', '= 5.0.4'
  s.dependency 'ThingSmartHomeKit','= 5.0.0'
  s.dependency 'CryptoSwift', '= 1.3.8'
  s.dependency 'HejhomeSDKCommon', '= 1.0.1'
  
  s.resource_bundles = { 'HejhomeSDKBase' => ['Base/Assets/**/*.{xib,xcassets}'] }
  
end
