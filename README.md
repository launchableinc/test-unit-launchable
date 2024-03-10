# Test::Unit::Launchable

test-unit-launchable is a convinient plugin for test-unit that generates a Launchable test report file based on the test results.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add test-unit-launchable

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install test-unit-launchable

## Usage

```ruby
require "test/unit/runner/launchable"
```

```
ruby test/example_test.rb --runner=launchable --launchable-test-report-json=report.json
```

## CLI options

- --launchable-test-report-json=PATH
  - Report test results in [Launchable JSON format](https://www.launchableinc.com/docs/resources/integrations/raw/).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ono-max/test-unit-launchable.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
