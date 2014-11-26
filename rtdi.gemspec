# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'rtdi'
  s.version     = '1.0'
  s.date        = '2014-11-26'
  s.executables = %w(dashing)


  s.summary      = "Real-Time Dashboard for Icinga"
  s.description = "With this framework you can build real-time-dashboards with the most important serverstatus."
  s.authors      = ["Landkreis Lüneburg - IT-Service"]
  s.email        = ""
  s.homepage     = 'http://landkreis-lueneburg.de'
  s.license      = "Data licence Germany attribution version 1.0"
  s.requirements << "You need mk_livestatus to use Status!"
  s.requirements << "http://mathias-kettner.de/checkmk_livestatus.html"

  s.files = Dir['README.md', 'javascripts/**/*', 'templates/**/*','templates/**/.[a-z]*', 'lib/**/*']

  s.add_dependency('sass', '~> 3.2.12')
  s.add_dependency('coffee-script', '~> 2.2.0')
  s.add_dependency('execjs', '~> 2.0.2')
  s.add_dependency('sinatra', '~> 1.4.4')
  s.add_dependency('sinatra-contrib', '~> 1.4.2')
  s.add_dependency('thin', '~> 1.6.1')
  s.add_dependency('rufus-scheduler', '~> 2.0.24')
  s.add_dependency('thor', '~> 0.18.1')
  s.add_dependency('sprockets', '~> 2.10.1')
  s.add_dependency('rack', '~> 1.5.2')

  s.add_development_dependency('rake', '~> 10.1.0')
  s.add_development_dependency('haml', '~> 4.0.4')
  s.add_development_dependency('minitest', '~> 5.2.0')
  s.add_development_dependency('mocha', '~> 0.14.0')
  s.add_development_dependency('fakeweb', '~> 1.3.0')
  s.add_development_dependency('simplecov', '~> 0.8.2')
end
