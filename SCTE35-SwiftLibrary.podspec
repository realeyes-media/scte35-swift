#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'SCTE35-SwiftLibrary'
s.version          = '1.0.0'
s.summary          = 'SCTE Library for Swift.'
s.description      = 'Converts hex strings and base64 strings into SCTE 35 Objects per the specifications at https://www.scte.org/SCTEDocs/Standards/SCTE%2035%202016.pdf'
s.homepage         = 'https://github.com/realeyes-media/ios-vast-client'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { "John G. Gainfort, Jr." => "john@realeyes.com" }
s.source           = { :git => "https://bitbucket.org/JoesRealEyes/scte35-swiftlibrary", :branch => "master", :tag => s.version }

s.ios.deployment_target = '10.0'
s.tvos.deployment_target = '10.0'
s.swift_version = '5.0'
s.requires_arc = true

s.source_files  = "SCTE35-SwiftLibrary", "SCTE35-SwiftLibrary/**/*.{h,m}"

end
