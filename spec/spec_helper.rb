require_relative '../lib/fcleaner'
require 'awesome_print'
require 'fakeweb'

RSpec.configure do |config|
  config.mock_with :rspec do |mock|
    mock.verify_doubled_constant_names = true
  end
end

FakeWeb.allow_net_connect = false
