require 'cucumber'
require 'aruba/cucumber'
require 'adhearsion'

Before do
  @aruba_timeout_seconds = 30
end
