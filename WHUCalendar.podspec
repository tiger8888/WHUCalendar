
# WHUCalendar 
# Powered By Wangdahu QQ:422596694


Pod::Spec.new do |s|
  s.name             = 'WHUCalendar'
  s.version          = '0.1.2'
  s.summary          = 'A Lunar Calendar '
  s.author             = { "WangDahu" => "422596694@qq.com" }

  s.description      = <<-DESC
A Lunar Calendar,Fast,Tagged,Easy to Use
                       DESC

  s.homepage         = 'https://github.com/tiger8888/WHUCalendar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tiger8888' => 'seekarmor@139.com' }
  s.source           = { :git => 'https://github.com/tiger8888/WHUCalendar.git', :tag => s.version }

  s.ios.deployment_target = '7.0'
  s.platform     = :ios,'7.0'
  s.source_files = 'WHUCalendar/Classes/**/*'
  s.requires_arc = true 
  s.frameworks = 'UIKit'

end
