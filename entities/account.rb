# frozen_string_literal: true

module Entities
  class Account
    include Modules::ConsoleHelper
    include Modules::AccountValidate

    attr_reader :name, :age, :login, :password, :errors
    attr_accessor :cards, :file_path

    def initialize(arguments)
      @name = arguments[:name]
      @age = arguments[:age]
      @login = arguments[:login]
      @password = arguments[:password]
      @cards = []
      @errors = []
    end

    def valid?
      validate_login
      validate_age
      validate_name
      validate_password
      errors.empty?
    end

    def add_card(card)
      cards << card
    end

    def delete_card(card_index)
      cards.delete(card_index)
    end

    def destroy_account(current_account)
      return unless confirmed?(user_input('common.destroy_account'))

      accounts_left = accounts.delete_if { |account| account.login == current_account.login }
      save_data(accounts_left)
    end
  end
end
