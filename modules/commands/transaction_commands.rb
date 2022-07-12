# frozen_string_literal: true

module Modules
  module Commands
    module TransactionCommands
      include Modules::MoneyOperations

      def withdraw_money
        output_message('common.choose_card_withdrawing')
        current_card = find_card(@current_account)
        return unless current_card
        return unless withdraw_operation(current_card, user_input('common.withdraw_amount').to_i)

        store_card_data(@current_account)
      end

      def put_money
        output_message('common.choose_card')
        current_card = find_card(@current_account)
        return unless current_card
        return unless put_operation(current_card, user_input('common.input_amount').to_i)

        store_card_data(@current_account)
      end

      def send_money
        output_message('common.choose_card_sending')
        sender_card = find_card(current_account)
        recipient_card = find_card_number
        return unless recipient_card && sender_card
        return unless send_operation(sender_card, recipient_card,
                                     user_input('common.withdraw_amount').to_i)

        store_card_data(current_account)
      end

      private

      def store_card_data(current_account)
        accounts_to_store = []
        push_in_db(accounts_to_store, current_account)

        save_data(accounts_to_store)
      end
    end
  end
end
