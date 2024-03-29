require_relative 'lib/cpro/version'

Gem::Specification.new do |spec|
  spec.name          = "cpro"
  spec.version       = Cpro::VERSION
  spec.authors       = ["Nik Mikhaylichenko"]
  spec.email         = ["nn.mikh@yandex.ru"]

  spec.summary       = %q{CryproPro CSP wrapper}
  spec.description   = %q{Invoke CryptoPro CSP command with ruby}
  spec.homepage      = "http://example.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nmix/cpro"
  spec.metadata["changelog_uri"] = "https://github.com/nmix/cpro"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'dry-configurable', '~> 0.8.2'
  spec.add_dependency 'dry-core', '~> 0.4.7'
end
