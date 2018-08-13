lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'll/wk/api/version'

Gem::Specification.new do |spec|
  spec.name          = 'll_wk_api'
  spec.version       = LL::WK::API::VERSION
  spec.authors       = ['Matt Mofrad']
  spec.email         = ['m.mofrad@livelinktechnology.net']

  spec.summary       = 'Gem for interacting with livelink webkiosks'
  spec.homepage      = 'https://github.com/Zibby/wk_api_gem'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'curb'
  spec.add_dependency 'httparty'
end
