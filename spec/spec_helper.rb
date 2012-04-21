require 'adhearsion'
require 'flexmock'
require 'voicemail'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true

  config.mock_framework = :flexmock
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
