# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_translation_engine/version'

Gem::Specification.new do |spec|
  
  spec.name          = "simple_translation_engine"
  spec.version       = SimpleTranslationEngine::VERSION
  spec.authors       = ["Alex Bromley & Derek Edwards"]
  spec.email         = ["abromley@camsys.com,dedwards@camsys.com"]
  spec.summary       = "Intended to manage translations via at database."
  spec.description   = "Use I18n to provide translation services."
  spec.homepage      = "https://github.com/camsys/simple_translation_engine"
  spec.license       = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~>5.0"
  spec.add_dependency "sass-rails"
  spec.add_dependency "pg"
  spec.add_dependency "simple_form"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
