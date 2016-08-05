Pod::Spec.new do |s|
  s.name             = 'Ohana'
  s.version          = '1.0.0'
  s.summary          = 'Contacts simplified'
  s.homepage         = 'https://github.com/uber/ohana-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Nick Entin' => 'entin@uber.com',
                         'Maxwell Elliott' => 'maxwelle@uber.com',
                         'Doug Togno' => 'dtogno@uber.com' }
  s.source           = { :git => 'https://github.com/uber/Ohana.git', :tag => s.version.to_s }
  s.requires_arc     = true

  s.ios.deployment_target = '8.0'

  s.source_files = 'Ohana/Classes/**/*.{h,m}'

  s.frameworks = 'AddressBook', 'Contacts'

  s.dependency 'UberSignals', '~> 2.5'
  s.dependency 'libPhoneNumber-iOS', '~> 0.8'
end
