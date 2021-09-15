# frozen_string_literal: true

require "sap/auditlog"
require "sap/auditlog/message"
require "sap/auditlog/access_message"

require "time"
require "timecop"

require_relative "support/json_helpers"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Requests::JsonHelpers

  Timecop.safe_mode = true
end
