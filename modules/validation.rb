# frozen_string_literal: true

module Modules
  module Validation
    MIN_LOGIN_LENGTH = 4
    MAX_LOGIN_LENGTH = 20
    MIN_PASSWORD_LENGTH = 6
    MAX_PASSWORD_LENGTH = 30
    MIN_AGE = 23
    MAX_AGE = 90

    def valid_number?(value, min, max)
      value.nil? || (min..max).cover?(value)
    end

    def value_empty?(value)
      value.empty? || value == nil?
    end

    def value_long?(value, max)
      value.nil? || value.length > max
    end

    def value_short?(value, min)
      value.nil? || value.length < min
    end

    def value_exist?(value, stored_value)
      stored_value.include?(value)
    end
  end
end
