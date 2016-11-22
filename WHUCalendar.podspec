#
# Be sure to run `pod lib lint WHUCalendar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WHUCalendar'
  s.version          = '0.1.2'
  s.summary          = 'A Lunar Calendar '

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Lunar Calendar,Fast,Tagged,Easy to Use
                       DESC

  s.homepage         = 'https://github.com/tiger8888/WHUCalendar'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tiger8888' => 'seekarmor@139.com' }
  s.source           = { :git => 'https://github.com/tiger8888/WHUCalendar.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'WHUCalendar/Classes/**/*'
  
  s.frameworks = 'UIKit'


end
