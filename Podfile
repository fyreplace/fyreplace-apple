platform :ios, '12.4'

target 'Fyreplace' do
  use_frameworks!

  pod 'gRPC-Swift', '~> 1'
  pod 'gRPC-Swift-Plugins', '~> 1'
  pod 'ReactiveCocoa', '~> 12'
  pod 'Kingfisher', '~> 7'
  pod 'SwiftFormat/CLI', '~> 0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.4'
      next unless config.name == 'Release'
      config.build_settings['STRIPFLAGS'] = '-rSTx'
      config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'YES'
    end
  end
end
