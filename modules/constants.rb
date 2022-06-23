module Modules
  module Constants
    CARD_TYPES = %w[capitalist usual virtual].freeze
    FILE_PATH = 'data/accounts.yml'.freeze
    CREATE_COMMAND = 'create'.freeze
    LOAD_COMMAND = 'load'.freeze
    CARD_COMMANDS = %w[CC SC DC].freeze
    MONEY_COMMANDS = %w[PM WM SM].freeze
    AGREE_COMMAND = 'y'.freeze
    EXIT_COMMAND = 'exit'.freeze
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
