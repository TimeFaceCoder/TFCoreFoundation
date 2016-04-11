Pod::Spec.new do |s|
  s.name         = "TFCoreFoundation"
  s.version      = "0.0.1"
  s.summary      = "时光流影iOS基础框架"
  s.homepage     = "https://github.com/TimeFaceCoder/TFCoreFoundation"
  s.license      = "Copyright (C) 2016 TimeFace, Inc.  All rights reserved."
  s.author             = { "Melvin" => "yangmin@timeface.cn" }
  s.social_media_url   = "http://www.timeface.cn"
  s.ios.deployment_target = "7.1"
  s.source       = { :git => "https://github.com/TimeFaceCoder/TFCoreFoundation.git"}
  s.source_files  = "TFCoreFoundation/TFCoreFoundation/**/*.{h,m,c}"
  s.requires_arc = true
  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration'
  s.dependency 'JDStatusBarNotification'
  s.dependency 'JSONModel'
end
