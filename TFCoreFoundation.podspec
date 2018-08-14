Pod::Spec.new do |s|
  s.name         = "TFCoreFoundation"
  s.version      = "1.0.0"
  s.summary      = "时光流影iOS基础框架"
  s.homepage     = "https://git.coding.net/Timeface_xzx/TFCoreFoundation.git"
  s.license      = "Copyright (C) 2016 TimeFace, Inc.  All rights reserved."
  s.author             = { "Melvin" => "yangmin@timeface.cn" }
  s.social_media_url   = "http://www.timeface.cn"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://git.coding.net/Timeface_xzx/TFCoreFoundation.git"}
  s.source_files  = "TFCoreFoundation/**/*.{h,m,c}"
  s.requires_arc = true
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration'
  s.dependency 'JDStatusBarNotification'
  s.dependency 'NJKWebViewProgress'
  s.dependency 'JSONModel'
  s.dependency 'WebViewJavascriptBridge'
  s.dependency 'SAMKeychain'
  s.dependency 'pop'
  s.dependency 'YYImage'
  s.dependency 'FLAnimatedImage'
  s.dependency 'PINRemoteImage'
  s.dependency 'SDWebImage'
end
