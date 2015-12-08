# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "thin_search"
This.author   = [ "Jeremy Hinegardner", "Ara T. Howard"]
This.email    = [ "jeremy@copiousfreetime.org", "ara.t.howard@gmail.com" ]
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_dependency('amalgalite', '~> 1.5')

  spec.add_development_dependency( 'rake'     , '~> 10.3')
  spec.add_development_dependency( 'minitest' , '~> 5.7' )
  spec.add_development_dependency( 'rdoc'     , '~> 4.1' )
  spec.add_development_dependency( 'simplecov', '~> 0.10')
end

load 'tasks/default.rake'
