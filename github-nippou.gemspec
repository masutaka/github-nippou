# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github/nippou/version'

Gem::Specification.new do |spec|
  spec.name          = "github-nippou"
  spec.version       = Github::Nippou::VERSION
  spec.authors       = ["Takashi Masuda"]
  spec.email         = ["masutaka.net@gmail.com"]
  spec.summary       = %q{Outputs today's your GitHub action.}
  spec.description   = <<-EOS
    This is a helpful tool when you write a daily report in reference to
    GitHub. nippou is a japanese word which means a daily report.
  EOS
  spec.homepage      = "https://github.com/masutaka/github-nippou"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "octokit", "~> 3.7"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end
