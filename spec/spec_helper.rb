require "s3_mysql_backup"
require "rr"
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
  config.mock_framework = :rr
end
