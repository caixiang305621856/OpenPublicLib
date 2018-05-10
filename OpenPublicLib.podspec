#
# Be sure to run `pod lib lint OpenPublicLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OpenPublicLib'
  s.version          = '0.1.6'
  s.summary          = '公共服务基础组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 公用宏，公用函数，公用类的私有组件.
                       DESC

  s.homepage         = 'https://gitee.com/caixiang19901217/OpenPublicLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '616704162@qq.com' => 'caix@mail.open.cn' }
  s.source           = { :git => 'https://gitee.com/caixiang19901217/OpenPublicLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

    s.subspec 'Helper' do |h|
    h.source_files = 'OpenPublicLib/Classes/Helper/**/*'
    h.dependency 'OpenUDID'
    end

    s.subspec 'Macro' do |m|
    m.source_files = 'OpenPublicLib/Classes/Macro/**/*'
    end

    s.subspec 'FoundationCategory' do |f|
    f.source_files = 'OpenPublicLib/Classes/Category/Foundation/**/*'
    end

    s.subspec 'UIKitCategory' do |u|
    u.source_files = 'OpenPublicLib/Classes/Category/UIKit/**/*'
    u.dependency 'SDWebImage', '~> 4.2.3'
    end

    s.subspec 'NetWork' do |n|
    n.source_files = 'OpenPublicLib/Classes/NetWork/**/*'
    n.dependency 'AFNetworking', '~> 3.1'
    n.dependency 'FMDB'
    n.library = "sqlite3"
    end

  # s.resource_bundles = {
  #   'OpenPublicLib' => ['OpenPublicLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
end
