Pod::Spec.new do |s|
s.name         = 'LBXMLModel'
s.version      = '1.0'
s.summary      = 'iOS xml jsonmodel'
s.homepage     = 'https://github.com/MxABC/LBXMLModel'
s.license      = 'MIT'
s.authors      = {'lbxia' => 'lbxia20091227@foxmail.com'}
s.source       = {:git => 'https://github.com/MxABC/LBXMLModel.git', :tag => s.version}
s.requires_arc = true

s.ios.deployment_target = '6.0'
s.osx.deployment_target = '10.7'
s.watchos.deployment_target = '2.0'
s.tvos.deployment_target = '9.0'

s.source_files = 'LBXMLModel/*.{h,m}'
s.public_header_files = 'LBXMLModel/*.{h}'
s.dependency 'YYModel', '~> 1.0.4'
end

