require 'json'
require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/console/testrunner'

module Test
  module Unit
    module UI
      module Launchable
        module JSON
          class TestRunner < UI::Console::TestRunner
            def initialize(suite, options={})
              super
              @curt_test_case = nil
              @json_stream_writer = nil
            end

            def attach_to_mediator
              # To output logs to both stderr/stdout and an XML file,
              # `UI::Console::TestRunner#attach_to_mediator` is called here.
              super

              test_report = @options[:launchable_test_report]
              return unless test_report

              @json_stream_writer = JSONStreamWriter.new(test_report)
              @mediator.add_listener(::Test::Unit::TestCase::STARTED_OBJECT) do |test|
                @curt_test_case = LaunchableTestCase.new(test)
              end
              @mediator.add_listener(::Test::Unit::TestCase::FINISHED_OBJECT) do |test|
                @curt_test_case.elapsed_time = test.elapsed_time
                @json_stream_writer.open_nested_object do |writer|
                  # The test path is a URL-encoded representation.
                  # https://github.com/launchableinc/cli/blob/v1.81.0/launchable/testpath.py#L18
                  writer.write_key_value("testPath", @curt_test_case.test_path)
                  writer.write_key_value("duration", @curt_test_case.elapsed_time)
                  writer.write_key_value("status", @curt_test_case.status)
                  writer.write_key_value("stderr", @curt_test_case.stderr)
                  writer.write_key_value("stdout", nil)
                  writer.write_key_value("createdAt", Time.now.to_s)
                end
                @curt_test_case = nil
              end
              @mediator.add_listener(TestResult::FAULT) do |fault|
                @curt_test_case.fault = fault
              end
              @mediator.add_listener(TestRunnerMediator::FINISHED) do
                @json_stream_writer.close
              end
            end
          end

          class LaunchableTestCase
            attr_reader :method_name, :class_name, :source_location
            attr_accessor :fault, :elapsed_time

            def initialize(test)
              @method_name = test.method_name
              @class_name = test.class.name
              @failure_msg = ""
              @source_location = test.method(@method_name).source_location.first
            end

            def status
              case @fault
              when Pending, Omission
                'TEST_SKIPPED'
              when Error, Failure
                'TEST_FAILED'
              else
                'TEST_PASSED'
              end
            end

            def stderr
              @fault&.message
            end

            def test_path
              {file: @source_location, class: @class_name, testcase: @method_name}.map{|key, val|
                "#{encode_test_path_component(key)}=#{encode_test_path_component(val)}"
              }.join('#')
            end

            def encode_test_path_component component
              component.to_s.gsub('%', '%25').gsub('=', '%3D').gsub('#', '%23').gsub('&', '%26')
            end
          end

          class JSONStreamWriter
            class TestCaseWriter
              def initialize(file, indent)
                @file = file
                @indent = indent
                @file.puts
                @indent += 2
                write_indent
                @file.puts("{")
                @indent += 2
                @writer = KeyValueWriter.new(file, @indent)
              end

              def write_test_path_components(components)
                @writer.open_array("testPathComponents") do
                  components.each {|component|
                    @writer.open_nested_object do |obj_writer|
                      obj_writer.write_key_value("type", component[:type])
                      obj_writer.write_key_value("name", component[:name])
                    end
                  }
                end
              end

              def write_duration(duration)
                @writer.write_key_value("duration", duration)
              end

              def write_status(status)
                @writer.write_key_value("status", status)
              end

              def write_stdout(stdout)
                @writer.write_key_value("stdout", stdout)
              end

              def write_stderr(stderr)
                @writer.write_key_value("stderr", stderr)
              end

              def write_created_at(created_at)
                @writer.write_key_value("createdAt", created_at)
              end

              def close
                @writer.close
              end

              def write_indent
                @file.write(" " * @indent)
              end
            end

            class KeyValueWriter
              def initialize(file, indent)
                @indent = indent
                @file = file
                @is_first_key_val = true
                @is_first_element = true
              end

              def write_key_value(key, value)
                if @is_first_key_val
                  @is_first_key_val = false
                else
                  write_comma
                end
                @file.puts
                write_indent
                @file.write(to_json_str(key))
                @file.write(":", " ")
                @file.write(to_json_str(value))
              end

              def open_nested_object
                @file.puts("{")
                @indent += 2
                @writer = KeyValueWriter.new(file, @indent)
              end

              def open_nested_object
                if @is_first_element
                  @is_first_element = false
                else
                  write_comma
                end
                @indent += 2
                @file.puts
                write_indent
                @file.write("{")
                @indent += 2
                yield KeyValueWriter.new(@file, @indent)
                @indent -= 2
                @file.puts
                write_indent
                @file.write("}")
                @is_first_key_val = false
                @indent -= 2
              end

              def close
                @indent -= 2
                @file.puts
                write_indent
                @file.write("}")
              end

              def open_array(key)
                if @is_first_key_val
                  @is_first_key_val = false
                else
                  write_comma
                end
                write_indent
                @file.write(to_json_str(key))
                write_colon
                @file.write(" ")
                @file.write("[")
                yield
                @file.puts
                write_indent
                @file.write("]")
              end

              def close_array
                @file.puts
                write_indent
                @file.puts("]")
              end

              private

              def write_comma
                @file.write(',')
              end

              def write_indent
                @file.write(" " * @indent)
              end
  
              def to_json_str(obj)
                ::JSON.dump(obj)
              end

              def write_colon
                @file.write(":")
              end
            end

            class ArrayWriter
              def initialize(file, indent)
                @indent = indent
                @file = file
                @is_first_element = true
              end

              def open_array(key)
                write_indent
                @file.write(to_json_str(key))
                write_colon
                @file.write(" ")
                @file.write("[")
              end

              def close_array
                @file.puts
                write_indent
                @file.puts("]")
              end

              private

              def write_comma
                @file.write(',')
              end

              def write_indent
                @file.write(" " * @indent)
              end

              def write_colon
                @file.write(":")
              end

              def to_json_str(obj)
                ::JSON.dump(obj)
              end
            end

            def initialize path
              @file = File.open(path, "w")
              @indent = 2
              @file.puts("{")
              write_indent
              open_array("testCases")
              @file.flush
              @is_first_nested_obj = true
            end

            def write_test_case
              if @is_first_nested_obj
                @is_first_nested_obj = false
              else
                write_comma
              end
              writer = TestCaseWriter.new(@file, @indent)
              yield writer
              writer.close
            end

            def close
              close_array
              @file.puts("}")
              @file.flush
              @file.close
            end

            private

            def open_array(key)
              @file.write(to_json_str(key))
              write_colon
              @file.write(" ")
              @file.write("[")
            end

            def close_array
              @file.puts
              write_indent
              @file.puts("]")
            end

            def write_indent
              @file.write(" " * @indent)
            end

            def write_colon
              @file.write(":")
            end

            def write_comma
              @file.write(',')
            end

            def to_json_str(obj)
              ::JSON.dump(obj)
            end
          end
        end
      end
    end
  end
end
