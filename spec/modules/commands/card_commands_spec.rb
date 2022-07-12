# frozen_string_literal: true

RSpec.describe Modules::Commands::CardCommands do
  include Modules::ConsoleHelper
  include Modules::DataLoader
  subject(:card_service) { dummy.new }

  let(:dummy) { Class.new { include Modules::Commands::CardCommands } }
  let(:account) { Entities::Account.new(name: name, age: age, login: login, password: password) }
  let(:name) { Faker::Name.first_name }
  let(:age) { Faker::Number.between(from: 23, to: 90) }
  let(:login) { Faker::Internet.username(specifier: 4..20) }
  let(:password) { Faker::Internet.password(min_length: 6, max_length: 30) }
  let(:test_filename) { 'spec/fixtures/test_account.yml' }

  describe '#show_cards' do
    before do
      instance_variable_set(:@current_account, account)
    end

    let(:cards) { [Entities::Cards::UsualCard.new, Entities::Cards::VirtualCard.new] }

    it 'display cards if there are any' do
      cards.each do |card|
        account.add_card(card)
      end
      account.cards.each do |card|
        expect(I18n).to receive(:t).with('cards.card',  type: card.type, number: card.number)
      end
      show_cards
    end

    it 'outputs error if there are no active cards' do
      expect(I18n).to receive(:t).with('error.no_active_cards')
      show_cards
    end
  end

  describe '#create_card' do
    before do
      stub_const('Modules::Constants::FILE_PATH', test_filename)
      new_accounts_save(account)
      card_service.instance_variable_set(:@current_account, account)
    end

    context 'with correct outout' do
      before do
        allow(card_service).to receive_message_chain(:gets, :chomp) { 'usual' }
      end

      it do
        expect(I18n).to receive(:t).with('cards.create_card')
        card_service.create_card
      end
    end

    context 'when correct card choose' do
      cards = {
        usual: {
          type: 'usual',
          balance: 50.00
        },
        capitalist: {
          type: 'capitalist',
          balance: 100.00
        },
        virtual: {
          type: 'virtual',
          balance: 150.00
        }
      }

      after { FileUtils.rm_rf(test_filename) }

      cards.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          allow(card_service).to receive_message_chain(:gets, :chomp) { card_info[:type] }

          card_service.create_card

          expect(File.exist?(test_filename)).to be true
          file_accounts = YAML.load_file(test_filename)
          expect(file_accounts.first.cards.first.type).to eq card_info[:type]
          expect(file_accounts.first.cards.first.balance).to eq card_info[:balance]
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      before do
        allow(File).to receive(:open)
        allow(card_service).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')
      end

      it do
        expect { card_service.create_card }.to output(/#{I18n.t('error.wrong_card_type')}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    before do
      card_service.instance_variable_set(:@current_account, account)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { card_service.destroy_card }.to output(/#{I18n.t('common.if_you_want_to_delete')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:fake_cards) { [Entities::Cards::UsualCard.new, Entities::Cards::VirtualCard.new] }

      context 'with correct outout' do
        before do
          allow(card_service).to receive_message_chain(:gets, :chomp) { 'exit' }
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        it do
          expect { card_service.destroy_card }.to output(/#{I18n.t('common.if_you_want_to_delete')}/).to_stdout
        end
      end

      context 'when exit if first gets is exit' do
        before do
          fake_cards.each do |card|
            account.add_card(card)
          end
        end

        it do
          expect(card_service).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_service.destroy_card
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
            allow(card_service).to receive(:gets).and_return((fake_cards.length + 1).to_s, 'exit')
          end

          it { expect { card_service.destroy_card }.to output(/#{I18n.t('common.if_you_want_to_delete')}/).to_stdout }
        end

        context 'when negative input' do
          before do
            allow(card_service).to receive(:gets).and_return(-1.to_s, 'exit')
          end

          it { expect { card_service.destroy_card }.to output(/#{I18n.t('common.if_you_want_to_delete')}/).to_stdout }
        end
      end
    end
  end
end
