Pod::Spec.new do |s|
  s.name             = 'Ohana'
  s.version          = '2.0.0'
  s.summary          = 'Contacts simplified'
  s.homepage         = 'https://github.com/uber/ohana-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Nick Entin' => 'nick@entin.io',
                         'Maxwell Elliott' => 'maxwelle@uber.com',
                         'Doug Togno' => 'dtogno@uber.com',
                         'Adam Zethraeus' => 'adamz@uber.com' }
  s.source           = { :git => 'https://github.com/uber/ohana-ios.git', :tag => s.version.to_s }
  s.requires_arc     = true

  s.ios.deployment_target = '7.0'

  s.source_files = 'Ohana/Classes/**/*.{h,m}'

  s.frameworks = 'AddressBook', 'Contacts'

  s.dependency 'UberSignals', '~> 2.0'
  s.dependency 'libPhoneNumber-iOS', '~> 0.8'
end
