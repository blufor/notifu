Gem::Specification.new do |s|
  s.name                  = 'notifu'
  s.version               = '1.6.0'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = "Sensu notification handling service"
  s.description           = "Provides Nagios-like notification configuration & schedules"
  s.authors               = ["Radek 'blufor' Slavicinsky"]
  s.email                 = 'radek.slavicinsky@gmail.com'
  s.files                 = Dir['lib/**/*.rb']
  s.executables           = Dir['bin/*'].map(){ |f| f.split('/').last }
  s.homepage              = 'https://github.com/blufor/notifu'
  s.license               = 'GPL-3.0'
  s.required_ruby_version = '>= 2.2.0'
  s.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.0'
  s.add_runtime_dependency 'ohm', '~> 3.0', '>= 3.0.3'
  s.add_runtime_dependency 'elasticsearch', '~> 5.0', '>= 5.0.0'
  s.add_runtime_dependency 'sidekiq', '~> 4.2', '>= 4.2.6'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 0.19.0'
  s.add_runtime_dependency 'configuration', '~> 1.3', '>= 1.3.4'
  s.add_runtime_dependency 'thin', '~> 1.7', '>= 1.7.0'
  s.add_runtime_dependency 'grape', '~> 0.18', '>= 0.18.0'
  s.add_runtime_dependency 'activesupport', '~> 5.0', '>= 5.0.0.1'
  s.add_runtime_dependency 'log4r', '~> 1.1', '>= 1.1.10'
  s.add_runtime_dependency 'excon', '~> 0.54', '>= 0.54.0'
  s.add_runtime_dependency 'mail', '~> 2.6', '>= 2.6.0'
end
