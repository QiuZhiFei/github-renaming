# frozen_string_literal: true

require_relative "lib/github/renaming/version"

Gem::Specification.new do |spec|
  spec.name          = "github-renaming"
  spec.version       = Github::VERSION
  spec.authors       = ["qiuzhifei"]
  spec.email         = ["qiuzhifei521@gmail.com"]

  spec.summary       = "Renaming the default branch on Github"
  spec.description   = "Renaming the default branch on Github"
  spec.homepage      = "https://github.com/QiuZhiFei/github-renaming"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "thor",       "~> 1.1.0"
  spec.add_dependency "octokit",    "~> 4.21.0"
  spec.add_dependency "httparty",   "~> 0.18.1"
  spec.add_dependency "highline",   "~> 2.0.3"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
