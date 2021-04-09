require_relative 'lib/graphiti/rails/auto/version'

Gem::Specification.new do |spec|
  spec.name          = "graphiti-rails-auto"
  spec.version       = Graphiti::Rails::Auto::VERSION
  spec.authors       = ["Keith Bauson"]
  spec.email         = ["kwbauson@gmail.com"]

  spec.summary       = "Uses graphiti-rails to provide default models, controllers, and routes for resources that have been defined"
  spec.homepage      = "https://github.com/kwbauson/graphiti-rails-auto"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'graphiti'
  spec.add_dependency 'graphiti-rails'
  spec.add_dependency 'vandal_ui'
  spec.add_dependency 'kaminari'
  spec.add_dependency 'responders'
end
