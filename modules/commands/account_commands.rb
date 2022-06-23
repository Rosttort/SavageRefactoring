module Modules
  module Commands
    module AccountCommands
      include Modules::ConsoleHelper
      include Modules::Validation
      include Modules::DataLoader

      def create_account
        loop do
          account = Entities::Account.new(create_account_fields)
          account.errors.push(I18n.t('validation.login.exists')) if value_exist?(account.login, accounts.map(&:login))
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

      def destroy_account(current_account)
        return unless confirmed?(user_input('common.destroy_account'))

        accounts_left = accounts.delete_if { |account| account.login == current_account.login }
        save_data(file_path, accounts_left)
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
