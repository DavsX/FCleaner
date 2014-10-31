RSpec.configure do |config|
  config.mock_with :rspec do |mock|
    mock.verify_doubled_constant_names = true
  end
end
