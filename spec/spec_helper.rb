require 'unit_helper'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mock.verify_doubled_constant_names = true
  end
end
