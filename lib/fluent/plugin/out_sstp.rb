
module Fluent
  class Fluent::SstpOutput < Fluent::Output
    Fluent::Plugin.register_output('sstp', self)

    def initialize
      super
    end

    config_param :sstp_server, :string
    config_param :sstp_port, :integer, :default => 9801
    config_param :request_method, :string
    config_param :request_version, :string
    config_param :sender, :string
    config_param :script_template, :string

    def configure(conf)
      super

      @script = ERB.new(@script_template)
      raise "Unsupport post_type: #{@request_method}" unless @request_method == 'NOTIFY'
    end

    def start
      super
    end

    def shutdown
      super
    end

    def emit(tag, es, chain)
      es.each {|time,record|
        message = build_message(tag, time, record)
        post message
      }

      chain.next
    end

    def build_message tag, time, record
      script = @script.result(binding)
      ERB.new(<<-'EOS'
<%= @request_method %> <%= @request_version %>
Sender: <%= @sender %>
Script: <%= script %>
Charset: UTF-8
        EOS
      ).result(binding).gsub("\n", "\r\n")
    end

    def post(message)
      begin
        IO.popen("nc '#{@sstp_server}' '#{@sstp_port}'", 'w') do |io|
          io.puts message
        end
      rescue IOError, EOFError, SystemCallError
        # server didn't respond
        $log.warn "raises exception: #{$!.class}, '#{$!.message}'"
      end

      message
    end

  end
end
