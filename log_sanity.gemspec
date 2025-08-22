lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_sanity/version'

Gem::Specification.new do |spec|
  spec.name          = "log_sanity"
  spec.version       = LogSanity::VERSION
  spec.authors       = ["thomas morgan"]
  spec.email         = ["tm@iprog.com"]
  spec.homepage      = 'https://github.com/zarqman/log_sanity'
  spec.summary       = 'LogSanity - Bring sanity to Rails logs'
  spec.description   = 'LogSanity - Bring sanity to Rails logs by reducing verbosity, using json output, and more.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '>= 7.1.2', '< 8.1'
end
