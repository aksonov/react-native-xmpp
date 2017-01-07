Pod::Spec.new do |s|
  s.name         = "react-native-xmpp"
  s.version      = "0.2.1"
  s.license      = "MIT"
  s.homepage     = "https://github.com/aksonov/react-native-xmpp"
  s.authors      = { 'Marc Shilling' => 'marcshilling@gmail.com' }
  s.summary      = "A React Native module that allows you to use XMPP"
  s.source       = { :git => "https://github.com/aksonov/react-native-xmpp" }
  s.source_files  = "RNXMPP/*.{h,m}"

  s.platform     = :ios, "7.0"
  s.dependency 'React'
  s.dependency 'XMPPFramework'
end
