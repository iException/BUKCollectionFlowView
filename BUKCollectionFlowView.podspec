#
# Be sure to run `pod lib lint BUKCollectionFlowView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BUKCollectionFlowView"
  s.version          = "1.0.4"
  s.summary          = "a custom collection flow view"
  s.description      = "a custom collection flow view, usually used for show tags"
  s.homepage         = "https://github.com/iException/BUKCollectionFlowView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "huhuhumian" => "1152715@tongji.edu.cn" }
  s.source           = { :git => "https://github.com/iException/BUKCollectionFlowView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{h,m}'
  s.resource_bundles = {
    'BUKCollectionFlowView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
