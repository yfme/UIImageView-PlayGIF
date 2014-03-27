
Pod::Spec.new do |s|

  s.name         = "UIImageView+PlayGIF"
  s.version      = “1.0.0”
  s.summary      = "UIImageView category/subclass for playing GIF. Simple, high perfomence, low memory footprint."
  s.description  = <<-DESC
                   UIImageView category/subclass for playing GIF. Simple, high perfomence, low memory footprint.
                   DESC
  s.homepage     = "https://github.com/yfme/UIImageView-PlayGIF"
  # s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "yfme" => "yangfei.me@gmail.com" }
  # s.authors          = { "yfme" => "yangfei.me@gmail.com", "other author" => "email@address.com" }
  # s.social_media_url = "http://twitter.com/name"
  s.platform     = :ios, '5.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.source       = { :git => "https://github.com/yfme/UIImageView-PlayGIF.git", :tag => "0.0.1" }
  s.source_files  = 'UIImageView+PlayGIF/UIImageView+PlayGIF/*'
  # s.exclude_files = 'Classes/Exclude'
  # s.public_header_files = 'Classes/**/*.h'
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit', 'QuartzCore', 'ImageIO'
  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'
  s.requires_arc = true
  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  # s.dependency 'JSONKit', '~> 1.4'

end
