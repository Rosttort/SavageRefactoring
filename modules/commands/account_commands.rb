# frozen_string_literal: true

module Modules
  module Commands
    module AccountCommands
      include Modules::AccountValidate
      include Modules::ConsoleHelper

      def create_account
        loop do
          account = Entities::Account.new(create_account_fields)

          account_errors(account)
          new_accounts_save(account)
          break account if account.valid?

          show_errors(account.errors)
        end
      end

      def load_account
        loop do
          return create_the_first_account if accounts.empty?

          credentials_current = credentials_fields
          if accounts.any? { |account| account.authenticated?(credentials_current) }
            return @current_account = accounts.find { |account| credentials_current[:login] == account.login }
          end

          output_message('error.no_account')
        end
      end

      def create_the_first_account
        if user_input('common.create_first_account') ==
           Modules::Constants::AGREE_COMMAND
          main_console.create
        else
          main_console.console
        end
      end

      private

      def create_account_fields
        {
          name: user_input('input.name'),
          age: user_input('input.age').to_i,
          login: user_input('input.login'),
          password: user_input('input.password')
        }
      end

      def credentials_fields
        {
          login: user_input('input.login'),
          password: user_input('input.password')
        }
      end
    end
  end
end
