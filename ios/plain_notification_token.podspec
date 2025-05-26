#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plain_notification_token.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'plain_notification_token'
  s.version          = '0.0.1'
  s.summary          = 'Get your push notification token via platform way (APNs for iOS &#x2F; Firebase Clound Messaging for Android)'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'plain_notification_token/Sources/plain_notification_token/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'plain_notification_token_privacy' => ['plain_notification_token/Sources/plain_notification_token/PrivacyInfo.xcprivacy']}
end
