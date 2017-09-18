#
# Be sure to run `pod lib lint BrickKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BrickKit'
  s.version          = '2.4.1'
  s.summary          = 'BrickKit: a smart, easy, and consistent way of making layouts in iOS and tvOS.'

  s.description      = <<-DESC

  With BrickKit, you can create complex and responsive layouts in a simple way. It's easy to use and easy to extend. Create your own reusable bricks and behaviors.

                       DESC

  s.homepage         = 'https://github.com/wayfair/brickkit-ios'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Ruben Cagnie' => 'rcagnie@wayfair.com' }
  s.source           = { :git => 'https://github.com/wayfair/brickkit-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.1'
  s.tvos.deployment_target = '9.1'

  s.source_files = 'Source/**/*.swift'

  s.ios.resources = [
                    'Resources/iOS/*.{xcassets}',
                    'Resources/iOS/*/*/*.{xib}'
                    ]

  s.tvos.resources = [
		     'Resources/tvOS/*.{xcassets}',
                     'Resources/tvOS/*/*/*.{xib}'
                     ]
end
