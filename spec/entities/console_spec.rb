# frozen_string_literal: true

RSpec.describe Entities::Console do
  include Modules::ConsoleHelper
  include Modules::DataLoader
  subject(:console) { described_class.new }

  describe '#console' do
    context 'when success' do
      context 'when create account if input is create' do
        let(:create_command) { Modules::Constants::CREATE_COMMAND }

        before do
          allow(console).to receive_message_chain(:gets, :chomp) { create_command }
        end

        it do
          expect(console).to receive(:create)
          console.console
        end
      end

      context 'when load account if input is load' do
        let(:load_command) { Modules::Constants::LOAD_COMMAND }

        before do
          allow(console).to receive_message_chain(:gets, :chomp) { load_command }
        end

        it do
          expect(console).to receive(:load)
          console.console
        end
      end

      context 'when leave app if input is exit or some another word' do
        before do
          allow(console).to receive_message_chain(:gets, :chomp) { 'another' }
        end

        it do
          expect(console).to receive(:exit)
          console.console
        end
      end

      context 'with correct output' do
        before do
          allow(console).to receive_message_chain(:gets, :chomp) { 'test' }
          allow(console).to receive(:exit)
        end

        it do
          expect(I18n).to receive(:t).with(:hello)
          console.console
        end
      end
    end
  end

  describe '#main_menu' do
    let(:account) { Entities::Account.new(name: name, age: age, login: login, password: password) }
    let(:name) { Faker::Name.first_name }
    let(:age) { Faker::Number.between(from: 23, to: 90) }
    let(:login) { Faker::Internet.username(specifier: 4..20) }
    let(:password) { Faker::Internet.password(min_length: 6, max_length: 30) }
    let(:test_filename) { 'spec/fixtures/test_account.yml' }

    context 'with correct outout' do
      before do
        stub_const('Modules::Constants::FILE_PATH', test_filename)
        new_accounts_save(account)
        console.instance_variable_set(:@current_account, account)
        allow(console).to receive(:show_cards)
        allow(console).to receive(:exit)
        allow(console).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
      end

      after { FileUtils.rm_rf(test_filename) }

      it { expect { console.main_menu }.to output(/Welcome, #{account.name}/).to_stdout }
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }
      let(:commands) do
        {
          Modules::Constants::OPERATIONS[:show_cards] => :show_cards,
          Modules::Constants::OPERATIONS[:create_card] => :create_card,
          Modules::Constants::OPERATIONS[:destroy_card] => :destroy_card,
          Modules::Constants::OPERATIONS[:put_money] => :put_money,
          Modules::Constants::OPERATIONS[:withdraw_money] => :withdraw_money,
          Modules::Constants::OPERATIONS[:send_money] => :send_money
        }
      end

      after { FileUtils.rm_rf(test_filename) }

      before do
        stub_const('Modules::Constants::FILE_PATH', test_filename)
        new_accounts_save(account)
        console.instance_variable_set(:@current_account, account)
        allow(console).to receive(:exit)
        allow(console).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        allow(I18n).to receive(:t).with(:welcome, user_name: account.name)
        allow(I18n).to receive(:t).with(:main_menu)
      end

      it 'calls specific methods on predefined commands' do
        commands.each do |command, method_name|
          expect(console).to receive(method_name)
          allow(console).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          console.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        expect(I18n).to receive(:t).with('error.wrong_command')
        console.main_menu
      end
    end
  end
end
