# frozen_string_literal: true

module Entities
  class Console
    include Modules::Commands::AccountCommands
    include Modules::Commands::CardCommands
    include Modules::Commands::TransactionCommands
    include Modules::ConsoleHelper

    attr_accessor :file_path, :current_account, :transaction_commands

    def initialize
      @file_path = Modules::Constants::FILE_PATH
    end

    def console
      scenario = user_input(:hello)
      case scenario
      when Modules::Constants::CREATE_COMMAND then create
      when Modules::Constants::LOAD_COMMAND then load
      else exit
      end
    end

    private

    def create
      @current_account = create_account
      new_accounts = accounts << current_account
      save_data(@file_path, new_accounts)
      main_menu
    end

    def main_menu
      loop do
        output_message(:welcome, user_name: current_account.name)
        command = user_input(:main_menu)
        break Modules::Constants::EXIT_COMMAND if exit?(command)

        check_command(command)
      end
    end

    def check_command(command)
      case command.upcase
      when *Modules::Constants::CARD_COMMANDS then card_command_choose(command)
      when *Modules::Constants::MONEY_COMMANDS then money_command_choose(command)
      when Modules::Constants::OPERATIONS[:destroy_account] then current_account.destroy_account(current_account)
      else output_message('error.wrong_command')
      end
    end

    def load
      @current_account = load_account
      main_menu
    end

    def card_command_choose(command)
      case command.upcase
      when Modules::Constants::OPERATIONS[:show_cards] then show_cards
      when Modules::Constants::OPERATIONS[:create_card] then create_card
      when Modules::Constants::OPERATIONS[:destroy_card] then destroy_card
      when Modules::Constants::EXIT_COMMAND then main_menu
      else output_message('error.wrong_command')
      end
    end

    def money_command_choose(command)
      case command
      when Modules::Constants::OPERATIONS[:put_money] then put_money
      when Modules::Constants::OPERATIONS[:withdraw_money] then withdraw_money
      when Modules::Constants::OPERATIONS[:send_money] then send_money
      when Modules::Constants::EXIT_COMMAND then main_menu
      else output_message('error.wrong_command')
      end
    end
  end
end
