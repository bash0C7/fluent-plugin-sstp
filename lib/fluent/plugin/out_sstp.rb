require "fluent/plugin/output"
require "erb"
require "socket"

module Fluent
  module Plugin
    class SstpOutput < Output
      Fluent::Plugin.register_output("sstp", self)

      # Configuration parameters
      config_param :sstp_server, :string
      config_param :sstp_port, :integer, default: 9801
      config_param :request_method, :string
      config_param :request_version, :string
      config_param :sender, :string
      config_param :script_template, :string

      def configure(conf)
        super
        @script_erb = ERB.new(@script_template)
        raise Fluent::ConfigError, "Unsupported request_method: #{@request_method}" unless @request_method == 'NOTIFY'
      end

      def process(tag, es)
        es.each do |time, record|
          message = build_message(tag, time, record)
          post(message)
        end
      end

      def build_message(tag, time, record)
        # Generate the script content using the template
        rendered_script = @script_erb.result(binding)
        
        # Build the complete SSTP message
        ERB.new(<<-'EOS'
<%= @request_method %> <%= @request_version %>
Sender: <%= @sender %>
Script: <%= rendered_script %>
Charset: UTF-8
        EOS
        ).result(binding).gsub("\n", "\r\n")
      end

      def post(message)
        begin
          socket = TCPSocket.new(@sstp_server, @sstp_port)
          socket.puts(message)
          socket.close
        rescue => e
          log.warn "Failed to send SSTP message: #{e.class}, '#{e.message}'"
        end
        message
      end
    end
  end
end
