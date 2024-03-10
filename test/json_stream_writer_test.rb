
require_relative '../lib/test/unit/ui/launchable/json/testrunner'
require "test/unit"
require 'tempfile'
require 'json'

module DEBUGGER__
  class JSONStreamWriterTest < Test::Unit::TestCase
    def test_test_case_writer
      Tempfile.create(['launchable-test-', '.json']) do |f|
        json_stream_writer = Test::Unit::UI::Launchable::JSON::JSONStreamWriter.new(f.path)
        json_stream_writer.write_test_case do |writer|
          writer.write_test_path_components([
            {
              type: "file",
              name: "login/test_a.py"
            },
            {
              type: "class",
              name: "class1"
            },
            {
              type: "testcase",
              name: "testcase899"
            }
          ])
          writer.write_duration(42)
          writer.write_status("TEST_PASSED")
          writer.write_stdout("This is stdout")
          writer.write_stderr("This is stderr")
          writer.write_created_at("2021-10-05T12:34:00")
        end
        json_stream_writer.write_test_case do |writer|
          writer.write_test_path_components([
            {
              "type": "file",
              "name": "login/test_c.py"
            },
            {
              "type": "class",
              "name": "class2"
            },
            {
              "type": "testcase",
              "name": "testcase900"
            }
          ])
          writer.write_duration(45)
          writer.write_status("TEST_FAILED")
          writer.write_stdout("This is stdout")
          writer.write_stderr("This is stderr")
          writer.write_created_at("2021-10-05T12:35:00")
        end
        json_stream_writer.close()
        expected = <<~JSON
{
  "testCases": [
    {
      "testPathComponents": [
        {
          "type": "file",
          "name": "login/test_a.py"
        },
        {
          "type": "class",
          "name": "class1"
        },
        {
          "type": "testcase",
          "name": "testcase899"
        }
      ],
      "duration": 42,
      "status": "TEST_PASSED",
      "stdout": "This is stdout",
      "stderr": "This is stderr",
      "createdAt": "2021-10-05T12:34:00"
    },
    {
      "testPathComponents": [
        {
          "type": "file",
          "name": "login/test_c.py"
        },
        {
          "type": "class",
          "name": "class2"
        },
        {
          "type": "testcase",
          "name": "testcase900"
        }
      ],
      "duration": 45,
      "status": "TEST_FAILED",
      "stdout": "This is stdout",
      "stderr": "This is stderr",
      "createdAt": "2021-10-05T12:35:00"
    }
  ]
}
        JSON
        assert_equal(expected, f.read)
        f.close
      end
    end
  end
end
