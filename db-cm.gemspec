# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db-cm/version'

Gem::Specification.new do |gem|
  gem.name          = "db-cm"
  gem.version       = Db::Cm::VERSION
  gem.authors       = ["rajeevsood"]
  gem.email         = ["foo@bar.com"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('thor')
  gem.add_dependency('terminal-table')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('watchr')
  gem.add_development_dependency('debugger')
  gem.add_development_dependency('bundler')

end
