lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github/nippou/version'

Gem::Specification.new do |spec|
  spec.name          = 'github-nippou'
  spec.version       = Github::Nippou::VERSION
  spec.authors       = ['Takashi Masuda']
  spec.email         = ['masutaka.net@gmail.com']
  spec.summary       = %q{Print today's your GitHub action.}
  spec.description   = <<-EOS
    This is a helpful tool when you write a daily report in reference to
    GitHub. nippou is a japanese word which means a daily report.
  EOS
  spec.homepage      = 'https://github.com/masutaka/github-nippou'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'highline'
  spec.add_dependency 'launchy'
  spec.add_dependency 'octokit'
  spec.add_dependency 'parallel'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
