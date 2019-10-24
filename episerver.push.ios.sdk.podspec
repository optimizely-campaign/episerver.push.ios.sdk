#
# Be sure to run `pod lib lint episerver.push.ios.sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'episerver.push.ios.sdk'
  s.version          = '0.1.0'
  s.summary          = 'A software development kit (SDK), that facilitates sending push messages from Episerver Campaign to an iOS app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The SDK registers the app at Google Firebase and retrieves a registration token,
which is then fowarded to Episerver Campaign and can be used to send push messages
to the app.
                       DESC

  s.homepage         = 'https://github.com/episerver/episerver.push.ios.sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Till Klister' => 'till.klister@episerver.com' }
  s.source           = { :git => 'https://github.com/episerver/episerver.push.ios.sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/episerver'

  s.ios.deployment_target = '10.0'

  s.source_files = 'episerver.push.ios.sdk/Classes/**/*'
  
  # s.resource_bundles = {
  #   'episerver.push.ios.sdk' => ['episerver.push.ios.sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.static_framework = true
  s.dependency 'FirebaseMessaging', '~> 4.1'
  s.dependency 'FirebaseCore', '~> 6.3'
end
