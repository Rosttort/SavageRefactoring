HELLO_PHRASES = [
  I18n.t(:hello)
].freeze

OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze

ASK_PHRASES = I18n.t(:input).freeze

ACCOUNT_VALIDATION_PHRASES = I18n.t(:validation).freeze

ERROR_PHRASES = I18n.t(:error).freeze

COMMON_PHRASES = I18n.t(:common).freeze

CREATE_CARD_PHRASES = [
  I18n.t('cards.create_card')
].freeze

MAIN_OPERATIONS_TEXTS = [
  I18n.t(:main_menu)
].freeze

CARDS = {
  capitalist: CapitalistCard.new,
  usual: UsualCard.new,
  virtual: VirtualCard.new
}.freeze

RSpec.describe Console do
  let(:current_subject) { described_class.new }
  let(:account_commands) { current_subject.account_commands }
  let(:card_commands) { current_subject.card_commands }
  let(:transaction_commands) { current_subject.transaction_commands }

  before { stub_const('Modules::Constants::FILE_PATH', OVERRIDABLE_FILENAME) }

  describe '#console' do
    context 'when correct method calling' do
      after do
        current_subject.console
      end

      it 'create account if input is create' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'create' }
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'load' }
        expect(current_subject).to receive(:load)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(current_subject).to receive(:exit)
      end
    end

    context 'with correct output' do
      it do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(current_subject).to receive(:exit)
        HELLO_PHRASES.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        current_subject.console
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:account) do
      Account.new(
        name: success_name_input,
        age: success_age_input,
        login: success_login_input,
        password: success_password_input
      )
    end
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    context 'with success result' do
      before do
        allow(account_commands).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct output' do
        allow(File).to receive(:open)
        ASK_PHRASES.each_value { |phrase| expect(account_commands).to receive(:puts).with(phrase) }
        ACCOUNT_VALIDATION_PHRASES.values.map(&:values).each do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.create
      end

      it 'write to file Account instance' do
        current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive(:create)
        allow(account_commands).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists] }

          before do
            allow(account_commands).to receive(:accounts) { [instance_double(Account, login: error_input)] }
          end

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age][:length] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter] }

          it { expect { account_commands.create_account }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        allow(account_commands).to receive(:accounts).and_return([])
        allow(account_commands).to receive(:create_the_first_account).and_return([])
        expect(account_commands.accounts).to be_empty
        account_commands.load_account
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(account_commands).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(account_commands).to receive(:accounts) { [Account.new(login: login, password: password)] }
      end

      context 'with correct output' do
        let(:all_inputs) { [login, password] }

        it do
          allow(current_subject).to receive(:main_menu)
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(account_commands).to receive(:puts).with(phrase)
          end
          account_commands.load_account
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          allow(current_subject).to receive(:main_menu)
          expect { account_commands.load_account }.not_to output(/#{ERROR_PHRASES[:no_account]}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          allow(current_subject).to receive(:main_menu)
          expect { account_commands.load_account }.to output(/#{ERROR_PHRASES[:no_account]}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct output' do
      allow(account_commands).to receive_message_chain(:gets, :chomp) { '' }
      expect(current_subject).to receive(:console)
      expect { account_commands.create_the_first_account }.to output(COMMON_PHRASES[:create_first_account]).to_stdout
    end

    it 'calls create if user inputs is y' do
      allow(account_commands).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create)
      account_commands.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      allow(account_commands).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:console)
      account_commands.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:card_command) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card
      }
    end
    let(:transaction_command) do
      {
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money
      }
    end

    context 'with correct output' do
      it do
        allow(card_commands).to receive(:show_cards)
        allow(card_commands).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name))
        expect { current_subject.main_menu }.to output(/Welcome, #{name}/).to_stdout
        MAIN_OPERATIONS_TEXTS.each do |text|
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
          expect { current_subject.main_menu }.to output(/#{text}/).to_stdout
        end
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined card commands' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name, cards: []))

        card_commands.instance_variable_set(:@current_account, instance_double(Account, name: name, cards: []))

        card_command.each do |command, _|
          expect(current_subject).to receive(:card_command_choose).with(command)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'calls transaction methods on predefined transaction commands' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name, cards: []))

        transaction_commands.instance_variable_set(:@current_account, instance_double(Account, name: name))

        transaction_command.each do |command, _|
          expect(current_subject).to receive(:money_command_choose).with(command)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name))
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.main_menu }.to output(/#{ERROR_PHRASES[:wrong_command]}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double(Account, login: correct_login) }
    let(:fake_account) { instance_double(Account, login: fake_login) }
    let(:fake_account2) { instance_double(Account, login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'with correct output' do
      allow(account_commands).to receive_message_chain(:gets, :chomp) { '' }
      expect { account_commands.destroy_account 'account' }.to output(COMMON_PHRASES[:destroy_account]).to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        allow(account_commands).to receive_message_chain(:gets, :chomp) { success_input }
        allow(account_commands).to receive(:accounts) { accounts }
        account_commands.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        account_commands.instance_variable_set(:@current_account, instance_double(Account, login: correct_login))

        account_commands.destroy_account(correct_account)

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        allow(account_commands).to receive_message_chain(:gets, :chomp) { cancel_input }

        account_commands.destroy_account('current_account')

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [CapitalistCard.new, UsualCard.new] }
    let(:current_account) { Account.new({}) }

    it 'display cards if there are any' do
      current_account.instance_variable_set(:@cards, cards)
      card_commands.instance_variable_set(:@current_account, current_account)
      cards.each { |card| expect(card_commands).to receive(:puts).with("- #{card.number}, #{card.type}") }
      card_commands.show_cards
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@cards, [])
      card_commands.instance_variable_set(:@current_account, current_account)
      expect(card_commands).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
      card_commands.show_cards
    end
  end

  describe '#create_card' do
    let(:current_account) { Account.new({}) }

    context 'with correct output' do
      it do
        CREATE_CARD_PHRASES.each { |phrase| expect(card_commands).to receive(:puts).with(phrase) }
        card_commands.instance_variable_set(:@current_account, current_account)
        allow(card_commands).to receive(:accounts).and_return([])
        allow(File).to receive(:open)
        allow(card_commands).to receive_message_chain(:gets, :chomp) { 'usual' }
        expect(current_account).to receive(:add_card)
        card_commands.create_card
      end
    end

    context 'when correct card choose' do
      before do
        allow(card_commands).to receive(:accounts) { [current_account] }
        card_commands.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        card_commands.instance_variable_set(:@current_account, current_account)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          allow(card_commands).to receive_message_chain(:gets, :chomp) { card_info.type }

          card_commands.create_card

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards.first.type).to eq card_info.type
          expect(file_accounts.first.cards.first.balance).to eq card_info.balance
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        current_subject.instance_variable_set(:@card, [])
        card_commands.instance_variable_set(:@current_account, current_account)
        allow(File).to receive(:open)
        allow(card_commands).to receive(:accounts).and_return([])
        allow(card_commands).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { card_commands.create_card }.to output(/#{ERROR_PHRASES[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        card_commands.instance_variable_set(:@current_account, instance_double(Account, cards: []))
        expect { card_commands.destroy_card }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { CapitalistCard.new }
      let(:card_two) { UsualCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { Account.new({}) }

      context 'with correct output' do
        it do
          current_account.instance_variable_set(:@cards, fake_cards)
          card_commands.instance_variable_set(:@current_account, current_account)
          allow(card_commands).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { card_commands.destroy_card }.to output(/#{COMMON_PHRASES[:if_you_want_to_delete]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_commands.destroy_card }.to output(message).to_stdout
          end
          card_commands.destroy_card
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_account.instance_variable_set(:@cards, fake_cards)
          card_commands.instance_variable_set(:@current_account, current_account)
          allow(card_commands).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect(current_account).not_to receive(:delete_card)
          card_commands.destroy_card
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_account.instance_variable_set(:@cards, fake_cards)
          card_commands.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(card_commands).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { card_commands.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_commands).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { card_commands.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          card_commands.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
          current_account.instance_variable_set(:@cards, fake_cards)
          allow(card_commands).to receive(:accounts) { [current_account] }
          card_commands.instance_variable_set(:@current_account, current_account)
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(card_commands).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { card_commands.destroy_card }.to change { current_account.cards.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(card_commands).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { card_commands.destroy_card }.not_to change(current_account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        transaction_commands.instance_variable_set(:@current_account, instance_double(Account, cards: []))
        expect { transaction_commands.put_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { Account.new({}) }

      context 'with correct output' do
        it do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
          allow(transaction_commands).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { transaction_commands.put_money }.to output(/#{COMMON_PHRASES[:choose_card]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { transaction_commands.put_money }.to output(message).to_stdout
          end
          transaction_commands.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
          allow(transaction_commands).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { transaction_commands.put_money }.not_to change(current_account.cards.sample, :balance)
          transaction_commands.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { transaction_commands.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { transaction_commands.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) do
          card = CapitalistCard.new
          card.balance = 50.0
          card
        end
        let(:card_two) do
          card = CapitalistCard.new
          card.balance = 100.0
          card
        end
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }
        let(:current_account) { instance_double(Account, cards: fake_cards) }

        before do
          transaction_commands.instance_variable_set(:@current_account, current_account)
          allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { transaction_commands.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { transaction_commands.put_money }.to output(/#{ERROR_PHRASES[:correct_amount]}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              expect { transaction_commands.put_money }.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
            end
          end

          context 'with tax lower than amount' do
            let(:custom_cards) do
              [
                { card: usual_card, balance: default_balance, tax: correct_money_amount_greater_than_tax * 0.02 },
                { card: capitalist_card, balance: default_balance, tax: 10 },
                { card: virtual_card, balance: default_balance, tax: 1 }
              ]
            end

            let(:usual_card) do
              card = UsualCard.new
              card.balance = default_balance
              card
            end
            let(:capitalist_card) do
              card = CapitalistCard.new
              card.balance = default_balance
              card
            end
            let(:virtual_card) do
              card = VirtualCard.new
              card.balance = default_balance
              card
            end

            let(:current_account) { Account.new({}) }
            let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

            after do
              File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
            end

            it do
              custom_cards.each do |custom_card|
                current_account.instance_variable_set(:@cards, [custom_card[:card], card_one, card_two])
                transaction_commands.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
                allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(*commands)
                allow(transaction_commands).to receive(:accounts) { [current_account] }
                new_balance = default_balance + correct_money_amount_greater_than_tax - custom_card[:tax]

                expect { transaction_commands.put_money }.to output(
                  /Money #{correct_money_amount_greater_than_tax} was put on #{
custom_card[:card].number}. Balance: #{new_balance}. Tax: #{custom_card[:tax]}/
                ).to_stdout

                expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
                file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
                expect(file_accounts.first.cards.first.balance).to eq(new_balance)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        transaction_commands.instance_variable_set(:@current_account, Account.new({}))
        expect { transaction_commands.withdraw_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) do
        card = CapitalistCard.new
        card.balance = 50.0
        card
      end
      let(:card_two) do
        card = CapitalistCard.new
        card.balance = 100.0
        card
      end
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { Account.new({}) }

      context 'with correct output' do
        it do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
          allow(transaction_commands).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect do
            transaction_commands.withdraw_money
          end.to output(/#{COMMON_PHRASES[:choose_card_withdrawing]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { transaction_commands.withdraw_money }.to output(message).to_stdout
          end
          transaction_commands.withdraw_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
          allow(transaction_commands).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { transaction_commands.withdraw_money }.not_to change(current_account.cards.sample, :balance)
          transaction_commands.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { transaction_commands.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { transaction_commands.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) do
          card = CapitalistCard.new
          card.balance = 50.0
          card
        end
        let(:card_two) do
          card = CapitalistCard.new
          card.balance = 100.0
          card
        end
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }
        let(:current_account) { Account.new({}) }

        before do
          current_account.instance_variable_set(:@cards, fake_cards)
          transaction_commands.instance_variable_set(:@current_account, current_account)
          allow(transaction_commands).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { transaction_commands.withdraw_money }.to output(/#{COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end
      end
    end
  end
end
