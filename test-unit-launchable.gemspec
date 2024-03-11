# frozen_string_literal: true

require_relative "lib/test/unit/launchable/version"

Gem::Specification.new do |spec|
  spec.name = "test-unit-launchable"
  spec.version = Test::Unit::Launchable::VERSION
  spec.authors = ["Naoto Ono"]
  spec.email = ["onoto1998@gmail.com"]

  spec.summary = "test-unit plugin that generates a Launchable test report file"
  spec.description = "test-unit-launchable is a convinient plugin for test-unit that generates a Launchable test report file based on the test results."
  spec.homepage = "https://github.com/ono-max/test-unit-launchable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "test-unit"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
