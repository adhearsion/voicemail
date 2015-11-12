require 'adhearsion'
require 'voicemail'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
