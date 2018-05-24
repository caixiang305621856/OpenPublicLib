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
TODO: 公用宏，公用函数，公用类的私有组件.Base
                       DESC

  s.homepage         = 'https://github.com/caixiang305621856/OpenPublicLib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '616704162@qq.com' => 'caix@mail.open.cn' }
  s.source           = { :git => 'https://github.com/caixiang305621856/OpenPublicLib.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

    s.subspec 'Base' do |b|
    b.source_files = 'OpenPublicLib/Classes/Base/**/*'
    b.public_header_files = 'OpenPublicLib/Classes/Base/**/*.h'
    b.dependency 'OpenPublicLib/UIKitCategory'
    b.dependency 'OpenPublicLib/FoundationCategory'
    b.dependency 'OpenPublicLib/Macro'
    b.dependency 'OpenPublicLib/Helper'
    b.dependency 'MJExtension'
    b.dependency 'MBProgressHUD'
    end
    
    s.subspec 'Check' do |c|
    c.source_files = 'OpenPublicLib/Classes/Check/**/*'
    c.public_header_files = 'OpenPublicLib/Classes/Check/**/*.h'
    c.dependency 'OpenPublicLib/Base'
    c.dependency 'OpenPublicLib/Helper'
    end
    
    s.subspec 'Helper' do |h|
    h.source_files = 'OpenPublicLib/Classes/Helper/**/*'
    h.public_header_files = 'OpenPublicLib/Classes/Helper/**/*.h'
    h.dependency 'OpenPublicLib/Macro'
    h.dependency 'OpenUDID'
    end

    s.subspec 'Macro' do |m|
    m.source_files = 'OpenPublicLib/Classes/Macro/**/*'
    m.public_header_files = 'OpenPublicLib/Classes/Macro/**/*.h'
    end

    s.subspec 'FoundationCategory' do |f|
    f.source_files = 'OpenPublicLib/Classes/Category/Foundation/**/*'
    f.public_header_files = 'OpenPublicLib/Classes/Category/Foundation/**/*.h'
    f.dependency 'OpenPublicLib/Macro'
    end

    s.subspec 'UIKitCategory' do |u|
    u.source_files = 'OpenPublicLib/Classes/Category/UIKit/**/*'
    u.public_header_files = 'OpenPublicLib/Classes/Category/UIKit/**/*.h'
    u.dependency 'OpenPublicLib/FoundationCategory'
    u.dependency 'OpenPublicLib/SVPullToRefresh'
    u.dependency 'SDWebImage', '~> 4.2.3'
    end

    s.subspec 'NetWork' do |n|
    n.source_files = 'OpenPublicLib/Classes/NetWork/**/*'
    n.public_header_files = 'OpenPublicLib/Classes/NetWork/**/*.h'
    n.dependency 'AFNetworking', '~> 3.1'
    n.dependency 'FMDB'
    n.library = "sqlite3"
    end

    s.subspec 'SVPullToRefresh' do |sv|
    sv.source_files = 'OpenPublicLib/Classes/SVPullToRefresh/**/*'
    sv.public_header_files = 'OpenPublicLib/Classes/SVPullToRefresh/**/*.h'
    sv.dependency 'OpenPublicLib/Macro'
    sv.dependency 'OpenPublicLib/Helper'
    end
  # s.resource_bundles = {
  #   'OpenPublicLib' => ['OpenPublicLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
end
