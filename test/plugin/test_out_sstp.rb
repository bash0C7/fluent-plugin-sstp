require_relative '../helper'
require 'fluent/plugin/out_sstp'
require 'socket' # Added for TCPServer

# Test class for SstpOutput Plugin
class SstpOutputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  setup do
    Fluent::Test.setup
  end

  # Helper method to create driver with configuration
  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::SstpOutput).configure(conf)
  end

  # Common test data
  def test_record
    { 'craw_card' => 'クロウカード！', 'otherfield' => 99 }
  end

  # Default configuration for tests
  def default_config
    %[
      sstp_server                127.0.0.1
      sstp_port                  9801
      request_method             NOTIFY
      request_version            SSTP/1.1
      sender                     カードキャプター
      script_template            \\0汝のあるべき姿に戻れ。<%= record['craw_card'] %>\\e
    ]
  end

  # Expected SSTP message format
  def expected_message
    message = <<-'EOS'
NOTIFY SSTP/1.1
Sender: カードキャプター
Script: \0汝のあるべき姿に戻れ。クロウカード！\e
Charset: UTF-8
    EOS
    message.gsub("\n", "\r\n")
  end

  sub_test_case 'configuration' do
    test 'basic configuration is valid' do
      d = create_driver(default_config)
      assert_equal '127.0.0.1', d.instance.sstp_server
      assert_equal 9801, d.instance.sstp_port
      assert_equal 'NOTIFY', d.instance.request_method
      assert_equal 'SSTP/1.1', d.instance.request_version
      assert_equal 'カードキャプター', d.instance.sender
      assert_equal '\0汝のあるべき姿に戻れ。<%= record[\'craw_card\'] %>\e', d.instance.script_template
    end
  end

  sub_test_case 'build_message' do
    test 'builds correct SSTP message format' do
      d = create_driver(default_config)
      time = event_time('2022-01-01 00:00:00')
      tag = 'test.tag'
      
      message = d.instance.build_message(tag, time, test_record)
      
      assert_equal expected_message, message
    end
  end
  
  sub_test_case 'process' do
    test 'sends message via TCPSocket' do
      d = create_driver(default_config)
      
      # Start a TCP server for testing
      server = TCPServer.new('127.0.0.1', 9801)
      received_data = nil
      
      # Run a server thread that accepts one connection
      server_thread = Thread.new do
        begin
          client = server.accept
          received_data = client.readpartial(1024)
          client.close
        rescue => e
          puts "Server thread error: #{e.message}"
        end
      end
      
      # Give the server some time to start
      sleep 0.5
      
      time = event_time('2022-01-01 00:00:00')
      d.run do
        d.feed('test.metrics', time, test_record)
      end
      
      # Wait for server thread to process data
      server_thread.join(2)
      server.close
      
      # Check if the received message matches the expected format
      assert_equal expected_message, received_data.force_encoding(Encoding::UTF_8)
    end
  end
end
