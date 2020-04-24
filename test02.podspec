#
# Be sure to run `pod lib lint test02.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'test02'
  s.version          = '0.1.6'
  s.summary          = 'A short description of test02.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/smileat/test02'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smileat' => 'zshan@chint.com' }
  s.source           = { :git => 'https://github.com/smileat/test02.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'test02/Classes/**/*'
  s.static_framework = true
#  s.ios.vendored_frameworks = "Pod/**/*.framework"
#  s.ios.vendored_libraries = "xxx/**/*.a”
  s.resource_bundles = {
    'test02' => ['test02/Assets/*.png']
  }

   s.public_header_files = 'Pod/**/*.h'
   s.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
   s.dependency 'Masonry'
   s.dependency 'MJExtension'
   s.dependency 'MBProgressHUD'
end
