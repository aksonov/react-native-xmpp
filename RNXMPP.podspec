require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name                = 'RNXMPP'
  s.version             = package['version']
  s.summary             = package['description']
  s.description         = package['description']
  s.homepage            = package['homepage']
  s.license             = package['license']
  s.author              = package['author']
  s.source              = { :git => 'https://github.com/hippware/react-native-xmpp.git', :tag => s.version }

  s.requires_arc        = true
  s.platform            = :ios, '8.0'
  
  s.dependency 'React'
  s.dependency 'XMPPFramework'
  s.preserve_paths      = 'package.json', 'index.js'
  s.source_files        = 'RNXMPP/XMPPFramework.h', 'RNXMPP/RNXMPPService.m', 'RNXMPP/RNXMPPService.h', 'RNXMPP/RNXMPPConstants.h', 'RNXMPP/RNXMPPConstants.m', 'RNXMPP/RNXMPP.h', 'RNXMPP/RNXMPP.m'
end
