# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rspec/retry/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yusuke Mito"]
  gem.email         = ["y310.1984@gmail.com"]
  gem.description   = %q{retry randomly failing example}
  gem.summary       = %q{retry randomly failing example}
  gem.homepage      = "http://github.com/y310/rspec-retry"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rspec-retry"
  gem.require_paths = ["lib"]
  gem.version       = RSpec::Retry::VERSION
  gem.add_runtime_dependency %{rspec}
  gem.add_development_dependency %q{guard-rspec}
  gem.add_development_dependency %q{pry-debugger}
end
