Pod::Spec.new do |s|
  s.name             = 'TuIdentidadSDK'
  s.version          = '1.1.4'
  s.summary          = 'Official Tu Identidad SDK for iOS to access Tu Identidad Platform'

  s.description      = <<-DESC
Used to integrate the Tu Identidad Platform with your iOS apps.
Validation Services:
- INE
                       DESC

  s.homepage         = 'https://github.com/tu-identidad/tu-identidad-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Munguia' => 'aaron.munguia@tuidentidad.com' }
  s.source           = { :git => 'https://github.com/tu-identidad/tu-identidad-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.platform = :ios, '10.0'
  s.swift_version = '5.0'
  s.requires_arc = true

  s.source_files = 'TuIdentidadSDK/Classes/**/*'
  
  s.resource_bundles = {
    'TuIdentidadSDK' => ['TuIdentidadSDK/Assets/*.{png,xib}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Alamofire', '~> 5.0.0-rc.3'
#  s.dependency 'Eureka', '~> 5.1.0'
  s.dependency 'HandyJSON', '~> 5.0.1'
  s.dependency 'JGProgressHUD'
  s.dependency 'MBDocCapture', '~> 0.1.4'
  s.dependency 'Toast-Swift', '~> 5.0.0'
end
