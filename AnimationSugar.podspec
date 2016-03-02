#
# Be sure to run `pod lib lint AnimationSugar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AnimationSugar"
  s.version          = "0.1.0"
  s.summary          = "Syntactic sugar for iOS animations."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  A tiny Swift library for cleaning up your animation code. Easily tweak options
  with fluent-style syntax, and avoid nested callback for multi-step animations.
                       DESC

  s.homepage         = "https://github.com/intrepidmatt/AnimationSugar"
  s.license          = 'MIT'
  s.author           = { "Matt Bridges" => "matt@intrepid.io" }
  s.source           = { :git => "https://github.com/intrepidmatt/AnimationSugar.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/rrridges'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
