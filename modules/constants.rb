# frozen_string_literal: true

module Modules
  module Constants
    CARD_TYPES = %w[capitalist usual virtual].freeze
    FILE_PATH = 'data/accounts.yml'
    CREATE_COMMAND = 'create'
    LOAD_COMMAND = 'load'
    CARD_COMMANDS = %w[CC SC DC].freeze
    MONEY_COMMANDS = %w[PM WM SM].freeze
    AGREE_COMMAND = 'y'
    EXIT_COMMAND = 'exit'
    LOGIN_MIN_LENGTH = 3
    LOGIN_MAX_LENGTH = 20
    CARD_NUMBER_LENGTH = 12
    OPERATIONS = { show_cards: 'SC',
                   create_card: 'CC',
                   destroy_card: 'DC',
                   put_money: 'PM',
                   withdraw_money: 'WM',
                   send_money: 'SM',
                   destroy_account: 'DA' }.freeze
  end
end
