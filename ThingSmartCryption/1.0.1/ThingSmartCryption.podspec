Pod::Spec.new do |s|
  s.name             = 'ThingSmartCryption'
  s.version          = '1.0.1'
  s.summary          = 'This is an encrypted SDK designed to ensure basic security.'
  s.description      = 'This is an encrypted SDK designed to ensure basic security.'
  s.homepage         = 'https://github.com/tuya'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ios' => 'developer@tuya.com' }
  s.source           = { :git => 'https://bitbucket.org/goqual-workspace/hejhome-pod-specs.git' }
  # s.prepare_command = <<-CMD

  #     if [ -f "ios_core_sdk.tar.gz" ]; then
  #       if [ ! -d "Build/ThingSmartCryption.xcframework" ]; then
  #         unzip ios_core_sdk.tar.gz
  #       fi
  #     else
  #       echo "File ios_core_sdk.tar.gz not found."
  #     fi

  # CMD
  s.ios.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.ios.source_files = 'ThingSmartCryption/1.0.1/Build/ThingSmartCryption.xcframework/ios*simulator/ThingSmartCryption.framework/Headers/*'
  s.resources = 'ThingSmartCryption/1.0.1/Build/ThingSmartCryption.xcframework/ios*simulator/**/*.bundle'

  s.watchos.source_files = 'ThingSmartCryption/1.0.1/Build/ThingSmartCryption.xcframework/watchos*simulator/ThingSmartCryption.framework/Headers/*'

  s.vendored_frameworks = 'ThingSmartCryption/1.0.1/Build/ThingSmartCryption.xcframework'

  s.user_target_xcconfig = { 
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
  s.pod_target_xcconfig = { 
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
  }
end
