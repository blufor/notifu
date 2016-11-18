Gem::Specification.new do |s|
  s.name                  = 'notifu'
  s.version               = '1.2'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = "Sensu notification handling service"
  s.description           = "Provides Nagios-like notification configuration & schedules"
  s.authors               = ["Radek 'blufor' Slavicinsky"]
  s.email                 = 'radek.slavicinsky@gmail.com'
  s.files                 = Dir['lib/**/*.rb']
  s.executables           = Dir['bin/*'].map(){ |f| f.split('/').last }
  s.homepage              = 'https://github.com/blufor/notifu'
  s.license               = 'GPL-3.0'
  s.required_ruby_version = '>= 2.3.1'
  s.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.0'
end
