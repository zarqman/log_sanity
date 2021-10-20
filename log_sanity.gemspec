lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_sanity/version'

Gem::Specification.new do |s|
  s.name          = "log_sanity"
  s.version       = LogSanity::VERSION
  s.authors       = ["thomas morgan"]
  s.email         = ["tm@iprog.com"]
  s.homepage      = 'https://github.com/zarqman/log_sanity'
  s.summary       = 'LogSanity - Bring sanity to Rails logs'
  s.description   = 'LogSanity - Bring sanity to Rails logs by reducing verbosity, using json output, and more.'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 5.2', '< 7.1'
end
