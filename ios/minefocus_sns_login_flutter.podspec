#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint minefocus_sns_login_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'minefocus_sns_login_flutter'
  s.version          = '0.0.1'
  s.summary          = 'sns login'
  s.description      = <<-DESC
sns login
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'scsk' => 'cong.wang3@pactera.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.dependency 'MFYConnect', '~> 1.0.1'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
