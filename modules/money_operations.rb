module Modules
  module MoneyOperations
    include Modules::ConsoleHelper
    include Modules::DataLoader

    def withdraw_operation(current_card, amount)
      return false unless check_amount(amount)
      return false if withdraw_not_enough?(current_card.balance, amount, current_card.withdraw_tax(amount))

      current_card.withdraw(amount)
      output_withdraw_message(amount, current_card)
      true
    end

    def put_operation(current_card, amount)
      return false unless check_amount(amount)
      return false if put_not_enough?(amount, current_card.put_tax(amount))

      current_card.put(amount)
      output_put_message(amount, current_card.number, current_card.put_tax(amount), current_card.balance)
      true
    end

    def send_operation(sender_card, recipient_card, amount)
      return false unless check_amount(amount)
      return false if withdraw_not_enough?(sender_card.balance, amount, sender_card.withdraw_tax(amount))
      return false if receive_not_enough?(amount, recipient_card.put_tax(amount))

      recipient_put(amount, recipient_card)

      sender_card.withdraw(amount)
      output_put_message(amount, sender_card, sender_card.sender_tax(amount), sender_card.balance)
      output_put_message(amount, recipient_card, recipient_card.put_tax(amount), recipient_card.balance)
      true
    end

    private

    def recipient_put(amount, recipient_card)
      recipient_card.put(amount)
      recipient_account = accounts.find { |a| a.cards.find { |s| s.number == recipient_card.number } }
      recipient_account.cards.map { |s| s.balance = recipient_card.balance if s.number == recipient_card.number }
      store_card_data_for_send_operation(recipient_account)
    end

    def store_card_data_for_send_operation(recipient_account)
      accounts_to_store = []
      push_in_db_for_recipient(accounts_to_store, recipient_account)
      save_data(@file_path, accounts_to_store)
    end

    def find_card_position_m(card)
      loop do
        show_cards_list(current_account.cards)
        input = gets.chomp
        break(Constants::EXIT_COMMAND) if exit?(input)

        card_position = card.to_i
        break(card_position) if card.valid_number?(card_position, 1, @cards.size)

        output_message('error.wrong_card')
      end
    end

    def withdraw_not_enough?(balance, amount, tax)
      return false if balance > tax + amount

      output_message('error.not_enough')
      true
    end

    def put_not_enough?(amount, tax)
      return false if tax < amount

      output_message('error.tax_higher')
      true
    end

    def receive_not_enough?(amount, tax)
      return false if tax < amount

      output_message('error.not_enough_sender')
      true
    end

    def check_amount(amount)
      return true if amount.positive?

      output_message('error.wrong_amount')
      false
    end

    def output_withdraw_message(amount, card)
      output_message(
        'money.withdraw',
        amount: amount,
        number: card.number,
        tax: card.withdraw_tax(amount),
        balance: card.balance
      )
    end

    def output_put_message(amount, number, tax, balance)
      output_message(
        'money.put',
        amount: amount,
        number: number,
        tax: tax,
        balance: balance
      )
    end
  end
end
