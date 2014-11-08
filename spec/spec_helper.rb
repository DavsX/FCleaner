require_relative '../lib/fcleaner'
require 'awesome_print'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :rspec do |mock|
    mock.verify_doubled_constant_names = true
  end
end

WebMock.disable_net_connect!
