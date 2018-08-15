#
# Be sure to run `pod lib lint TFCoreFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TFCoreFoundation'
  s.version          = '1.0.0'
  s.summary      = "时光流影iOS基础框架"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/TimeFaceCoder/TFCoreFoundation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'melvin7' => 'yangmin@timeface.cn' }
  s.source           = { :git => 'https://github.com/TimeFaceCoder/TFCoreFoundation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'TFCoreFoundation/Classes/**/*'
  
  s.resource_bundles = {
    'TFCoreFoundation' => ['TFCoreFoundation/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration'
  s.dependency 'JDStatusBarNotification'
  s.dependency 'NJKWebViewProgress'
  s.dependency 'JSONModel'
  s.dependency 'WebViewJavascriptBridge'
  s.dependency 'SAMKeychain'
  s.dependency 'pop'
  s.dependency 'YYImage'
  s.dependency 'FLAnimatedImage'
  s.dependency 'SDWebImage'
  s.dependency 'Masonry'
  s.dependency 'Texture'
  s.dependency 'TFNavigator'
  s.dependency 'TFTableViewDataSource'
end
