require 'spec_helper'

describe do
  let(:driver) {Fluent::Test::OutputTestDriver.new(Fluent::SstpOutput, 'test.metrics').configure(config)}
  let(:instance) {driver.instance}

  let(:record) {{ 'craw_card' => 'クロウカード！', 'otherfield' => 99}}
  let(:time) {0}

  describe 'build_message' do
    let(:tag) {'TAG'}

    let(:message) { s = <<-'EOS'
NOTIFY SSTP/1.1
Sender: カードキャプター
Script: \0汝のあるべき姿に戻れ。クロウカード！\e
Charset: UTF-8
      EOS
      s.gsub("\n", "\r\n")
    }

    let(:built) {instance.build_message(tag, time, record)}
    context 'empty custom_determine_color_code' do
      let(:script) {'\0汝のあるべき姿に戻れ。<%= record["craw_card"] %>\e'}
      let(:config) {
        %[
  sstp_server                127.0.0.1
  sstp_port                  9801
  request_method             NOTIFY
  request_version            SSTP/1.1
  sender                     カードキャプター
  script_template            #{script}
        ]
      }
      
      subject {built}
      it{should == message}
    end
  end
  
  describe 'emit' do
    let(:posted) {
      d = driver
      mock(IO).popen("nc '#{d.instance.sstp_server}' '#{d.instance.sstp_port}'", 'w').times 1
      d.emit(record, Time.at(time))
      d.run  
    }

    context 'empty custom_determine_color_code' do
      let(:config) {
        %[
  sstp_server                127.0.0.1
  sstp_port                  9801
  request_method             NOTIFY
  request_version            SSTP/1.1
  sender                     カードキャプター
  script_template            \0汝のあるべき姿に戻れ。<%= record['craw_card'] %>\e
        ]
      }

      subject {posted}
      it{should_not be_nil}
    end
  end
end