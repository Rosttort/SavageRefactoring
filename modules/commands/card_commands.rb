module Modules
  module Commands
    module CardCommands
      include Modules::ConsoleHelper
      include Modules::DataLoader
      include Modules::Validation

      def update_current_account_command(current_account)
        @current_account = current_account
      end

      def create_card
        accounts_to_store = []
        card_type = check_card
        type = "#{card_type.capitalize}Card"
        card = Entities::Cards.const_get(type.to_s).new
        current_account.add_card(card)
        push_in_db(accounts_to_store, current_account)
        save_data(@file_path, accounts_to_store)
      end

      def show_cards
        return output_message('error.no_active_cards') unless current_account.cards.any?

        show_cards_list(current_account.cards)
      end

      def destroy_card
        output_message('common.if_you_want_to_delete')
        current_card = find_card(current_account)
        return unless current_card
        return unless confirmed?(user_input('cards.confirm_deletion', number: current_card.number))

        accounts_to_store = []
        current_account.delete_card(current_card)
        push_in_db(accounts_to_store, current_account)
        save_data(@file_path, accounts_to_store)
      end
    end
  end
end
