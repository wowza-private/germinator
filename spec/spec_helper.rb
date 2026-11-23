# activesupport 6.1 uses Logger without requiring it and relied on
# concurrent-ruby (< 1.3.5) loading it as a side effect.
require "logger"
require "action_view"
require "germinator"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end
