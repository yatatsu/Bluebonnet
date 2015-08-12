# coding: utf-8
Pod::Spec.new do |s|

s.name         = "Bluebonnet"
s.version      = "0.4.0"
s.summary      = "A simple and type safe API client using Alamofire + SwiftTask."

s.description  = <<-DESC
Bluebonnet is a wrapper of Alamofire and SwiftTask for web API client.
It provides simple interface based on SwiftTask  with typed value response.
DESC

s.homepage     = "https://github.com/yatatsu/Bluebonnet"
s.license      = { :type => "MIT", :file => "LICENSE" }

s.author             = { "yatatsu" => "yatatsukitagawa@gmail.com" }
s.social_media_url   = "http://twitter.com/tatsuyakit"
s.platform     = :ios, "8.0"

s.source       = { :git => "https://github.com/yatatsu/Bluebonnet.git", :tag => s.version }
s.source_files = 'Bluebonnet/*.swift'

s.requires_arc = true

s.dependency "Alamofire", "1.3.1"
s.dependency "SwiftTask", "~> 3.3.0"

end
