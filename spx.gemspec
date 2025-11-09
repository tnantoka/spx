# frozen_string_literal: true

require_relative "lib/spx/version"

Gem::Specification.new do |spec|
  spec.name = "spx"
  spec.version = Spx::VERSION
  spec.authors = ["tnantoka"]
  spec.email = ["tnantoka@bornneet.com"]

  spec.summary = "Sonic Pi eXecutor"
  spec.description = "A CLI tool to play or record Sonic Pi code by using Sonic Pi's built-in OSC server."
  spec.homepage = "https://github.com/tnantoka/spx"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "osc-ruby", "~> 1.1"
  spec.add_dependency "ostruct", "~> 0.6.3"
  spec.add_dependency "thor", "~> 1.4"
end
