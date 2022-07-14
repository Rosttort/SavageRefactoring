# frozen_string_literal: true

module Modules
  module Commands
    module CardCommands
      include Modules::ConsoleHelper

      def create_card
        accounts_to_store = []
        type = "#{check_card.capitalize}Card"
        card = Entities::Cards.const_get(type).new
        @current_account.add_card(card)
        push_in_db(accounts_to_store, @current_account)
        save_data(accounts_to_store)
      end

      def destroy_card
        output_message('common.if_you_want_to_delete')
        current_card = find_card
        return unless current_card
        return unless confirmed?(user_input('cards.confirm_deletion', number: current_card.number))

        accounts_to_store = []
        @current_account.delete_card(current_card)
        push_in_db(accounts_to_store, @current_account)
        save_data(accounts_to_store)
      end
    end
  end
end
