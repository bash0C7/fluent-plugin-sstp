require "fluent/plugin/output"

module Fluent
  module Plugin
    class SstpOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("sstp", self)
    end
  end
end
