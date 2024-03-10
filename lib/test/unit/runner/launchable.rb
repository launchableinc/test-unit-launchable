require "test/unit/autorunner"

module Test
  module Unit
    AutoRunner.register_runner(:launchable) do |auto_runner|
      require_relative 'testrunner'
      Test::Unit::UI::Launchable::JSON::TestRunner
    end

    AutoRunner.setup_option do |auto_runner, opts|
      opts.on("--launchable-test-report-json=PATH", 'Report test results in Launchable JSON format') do |path|
        auto_runner.runner_options[:launchable_test_report] = path
      end
    end
  end
end
