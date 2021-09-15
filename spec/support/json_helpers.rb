# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json_sym(str)
      MultiJson.load(str, symbolize_keys: true)
    end
  end
end
