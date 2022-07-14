# frozen_string_literal: true

module Modules
  module DataLoader
    def load_data
      return [] unless File.exist?(Modules::Constants::FILE_PATH)

      YAML.load_file(Modules::Constants::FILE_PATH) || []
    end

    def save_data(data)
      File.write(Modules::Constants::FILE_PATH, data.to_yaml)
    end
  end
end
