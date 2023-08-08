
Pod::Spec.new do |s|
  s.name             = 'HejhomeSDKCamera'
  s.version          = '1.3.3'
  s.summary          = 'HejhomeSDKCamera'
  s.swift_versions   = '4.0'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://bitbucket.org/goqual-workspace/hejhome-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '김다솜' => 'dskim0704@goqual.com' }
  s.source           = { :git => 'https://bitbucket.org/goqual-workspace/hejhome-camera-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Camera/Classes/**/*'

  s.static_framework = true
  s.info_plist = {
        'CFBundleIdentifier' => 'org.cocoapods.HejhomeSDKCamera'
    }

  s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.frameworks = 'Foundation'

  s.dependency 'ThingSmartHomeKit','= 5.0.0'
  s.dependency 'ThingSmartCameraKit','= 5.6.0'
  s.dependency 'ThingCameraUIKit','= 5.0.0'
  s.dependency 'HejhomeSDKCommon','= 1.0.1'
  
end
