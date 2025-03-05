lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-sstp"
  spec.version = "0.1.0"
  spec.authors = ["bash0C7"]
  spec.email   = ["ksb.4038.nullpointer+github@gmail.com"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "Apache-2.0"

  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.6.2"
  spec.add_development_dependency "rake", "~> 13.2.1"
  spec.add_development_dependency "test-unit", "~> 3.6.7"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
