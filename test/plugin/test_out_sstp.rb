require_relative '../helper'
require 'fluent/plugin/out_sstp'

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
      
      # Mock socket using RR
      mock_socket = Object.new
      # TCPSocketクラスのnewメソッドをスタブ化
      stub(TCPSocket).new('127.0.0.1', 9801) { mock_socket }
      # mock_socketのメソッドに対する期待を設定
      mock(mock_socket).puts(is_a(String)) { true }
      mock(mock_socket).close { true }
      
      time = event_time('2022-01-01 00:00:00')
      d.run do
        d.feed('test.metrics', time, test_record)
      end
    end
  end
end
