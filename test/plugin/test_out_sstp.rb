require "helper"
require "fluent/plugin/out_sstp.rb"

class SstpOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::SstpOutput).configure(conf)
  end
end
