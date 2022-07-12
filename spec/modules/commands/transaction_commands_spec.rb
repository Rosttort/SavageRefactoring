# frozen_string_literal: true

RSpec.describe Modules::Commands::TransactionCommands do
  include Modules::ConsoleHelper
  include Modules::DataLoader
  subject(:transaction_service) { dummy.new }

  let(:dummy) { Class.new { include Modules::Commands::TransactionCommands } }
  let(:account) { Entities::Account.new(name: name, age: age, login: login, password: password) }
  let(:name) { Faker::Name.first_name }
  let(:age) { Faker::Number.between(from: 23, to: 90) }
  let(:login) { Faker::Internet.username(specifier: 4..20) }
  let(:password) { Faker::Internet.password(min_length: 6, max_length: 30) }
  let(:test_filename) { 'spec/fixtures/test_account.yml' }

  describe '#put_money' do
    before { transaction_service.instance_variable_set(:@current_account, account) }

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { transaction_service.put_money }.to output(/#{I18n.t('common.choose_card')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:fake_cards) { [Entities::Cards::UsualCard.new, Entities::Cards::VirtualCard.new] }

      context 'with correct outout' do
        before do
          allow(transaction_service).to receive(:gets).and_return('exit')
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        let(:expected_message) { message_for_put + cards_with_index.join + exit_message }
        let(:message_for_put) { I18n.t('common.choose_card') }
        let(:exit_message) { I18n.t('exit') }
        let(:cards_with_index) do
          fake_cards.each_with_index.map do |card, index|
            I18n.t('cards.card_with_index', type: card.type, number: card.number, index: index + 1)
          end
        end

        it do
          expect { transaction_service.put_money }.to output(expected_message).to_stdout
        end
      end

      context 'when exit if first gets is exit' do
        before do
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        it do
          expect(transaction_service).to receive(:gets).and_return('exit')
          transaction_service.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        context 'when input is bigger than card length' do
          before do
            allow(transaction_service).to receive(:gets).and_return((fake_cards.length + 1).to_s, 'exit')
          end

          it do
            expect { transaction_service.put_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
          end
        end

        context 'when negative input' do
          before do
            allow(transaction_service).to receive(:gets).and_return(-1.to_s, 'exit')
          end

          it do
            expect { transaction_service.put_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
          end
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { Entities::Cards::CapitalistCard.new }
        let(:card_two) { Entities::Cards::CapitalistCard.new }
        let(:cards) { [card_one, card_two] }
        let(:chosen_card_number) { '1' }
        let(:incorrect_money_amount) { '-2' }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { '5' }
        let(:correct_money_amount_greater_than_tax) { '50' }

        context 'with correct output' do
          let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

          before do
            allow(transaction_service).to receive(:gets).and_return(*commands)
            cards.each do |card|
              account.add_card(card)
            end
          end

          it do
            expect { transaction_service.put_money }.to output(/#{I18n.t('common.input_amount')}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          before do
            allow(transaction_service).to receive(:gets).and_return(*commands)
            cards.each do |card|
              account.add_card(card)
            end
          end

          it do
            expect { transaction_service.put_money }.to output(/#{I18n.t('common.input_amount')}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            before do
              allow(transaction_service).to receive(:gets).and_return(*commands)
              cards.each do |card|
                account.add_card(card)
              end
            end

            it { expect { transaction_service.put_money }.to output(/#{I18n.t('common.input_amount')}/).to_stdout }
          end

          context 'with tax lower than amount' do
            let(:custom_cards) do
              [
                Entities::Cards::UsualCard.new,
                Entities::Cards::CapitalistCard.new,
                Entities::Cards::VirtualCard.new
              ]
            end

            let(:commands) do
              [
                chosen_card_number, correct_money_amount_greater_than_tax,
                chosen_card_number, correct_money_amount_greater_than_tax,
                chosen_card_number, correct_money_amount_greater_than_tax
              ]
            end

            before do
              stub_const('Modules::Constants::FILE_PATH', test_filename)
              new_accounts_save(account)
              transaction_service.instance_variable_set(:@current_account, account)
              allow(transaction_service).to receive_message_chain(:gets, :chomp).and_return(*commands)
            end

            after do
              FileUtils.rm_rf(test_filename)
            end

            it do
              custom_cards.each do |card|
                account.cards = [card]
                tax = card.put_tax(correct_money_amount_greater_than_tax.to_i)
                new_balance = card.balance + correct_money_amount_greater_than_tax.to_i - tax

                transaction_service.put_money
                expect(File.exist?(test_filename)).to be true
                file_accounts = YAML.load_file(test_filename)
                expect(file_accounts.first.cards.first.balance).to eq(new_balance)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    before do
      transaction_service.instance_variable_set(:@current_account, account)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { transaction_service.withdraw_money }.to output(/#{I18n.t('common.choose_card_withdrawing')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:fake_cards) { [Entities::Cards::CapitalistCard.new, Entities::Cards::UsualCard.new] }
      let(:expected_message) { message_for_withdraw + cards_with_index.join + exit_message }
      let(:message_for_withdraw) { I18n.t('common.choose_card_withdrawing') }
      let(:exit_message) { I18n.t('exit') }
      let(:cards_with_index) do
        fake_cards.each_with_index.map do |card, index|
          I18n.t('cards.card_with_index', type: card.type, number: card.number, index: index + 1)
        end
      end

      context 'with correct outout' do
        before do
          allow(transaction_service).to receive_message_chain(:gets, :chomp) { 'exit' }
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        it { expect { transaction_service.withdraw_money }.to output(expected_message).to_stdout }
      end

      context 'when exit if first gets is exit' do
        before do
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        it do
          expect(transaction_service).to receive_message_chain(:gets, :chomp) { 'exit' }
          transaction_service.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        context 'when input is bigger than card length' do
          before do
            allow(transaction_service).to receive(:gets).and_return((fake_cards.length + 1).to_s, 'exit')
          end

          it { expect { transaction_service.withdraw_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout }
        end

        context 'when negative input' do
          before do
            allow(transaction_service).to receive(:gets).and_return(-1.to_s, 'exit')
          end

          it { expect { transaction_service.withdraw_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout }
        end
      end

      context 'with correct input of card number' do
        let(:fake_cards) { [Entities::Cards::CapitalistCard.new, Entities::Cards::CapitalistCard.new] }
        let(:chosen_card_number) { '1' }
        let(:incorrect_money_amount) { '-2' }
        let(:correct_money_amount_lower_than_tax) { '5' }
        let(:correct_money_amount_greater_than_tax) { '50' }

        before do
          allow(transaction_service).to receive_message_chain(:gets, :chomp).and_return(*commands)
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { transaction_service.withdraw_money }.to output(/#{I18n.t('common.withdraw_amount')}/).to_stdout
          end
        end
      end
    end
  end
end
