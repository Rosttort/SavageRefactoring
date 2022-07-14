# frozen_string_literal: true

RSpec.describe Modules::Commands::AccountCommands do
  include Modules::DataLoader
  include Modules::ConsoleHelper
  subject(:account_service) { dummy.new }

  let(:dummy) { Class.new { include Modules::Commands::AccountCommands } }
  let(:test_filename) { 'spec/fixtures/test_account.yml' }

  describe '#create' do
    let(:success_name_input) { Faker::Name.first_name }
    let(:success_age_input) { Faker::Number.between(from: Modules::Constants::AGE_MIN_LENGTH, to: Modules::Constants::AGE_MAX_LENGTH).to_s }
    let(:success_login_input) { Faker::Internet.username(specifier: Modules::Constants::LOGIN_MIN_LENGTH..Modules::Constants::LOGIN_MAX_LENGTH) }
    let(:success_password_input) { Faker::Internet.password(min_length: Modules::Constants::PASSWORD_MIN_LENGTH, max_length: Modules::Constants::PASSWORD_MAX_LENGTH) }

    let(:right_inputs) do
      [success_name_input, success_age_input, success_login_input, success_password_input]
    end

    context 'with success result' do
      before do
        stub_const('Modules::Constants::FILE_PATH', test_filename)
        allow(account_service).to receive(:gets).and_return(success_name_input, success_age_input,
                                                            success_login_input, success_password_input)
      end

      after do
        FileUtils.rm_rf(test_filename)
      end

      it 'with correct outout' do
        expect(I18n).to receive(:t).with('input.name')
        expect(I18n).to receive(:t).with('input.age')
        expect(I18n).to receive(:t).with('input.login')
        expect(I18n).to receive(:t).with('input.password')
        account_service.create_account
      end

      it 'write to file Account instance' do
        account_service.create_account
        expect(File.exist?(test_filename)).to be true
        accounts = YAML.load_file(test_filename)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
      end
    end

    context 'with errors' do
      before do
        allow(account_service).to receive(:loop).and_yield
        stub_const('Modules::Constants::FILE_PATH', test_filename)
        allow(account_service).to receive(:gets).and_return(*wrong_inputs)
      end

      after do
        FileUtils.rm_rf(test_filename)
      end

      context 'with name errors' do
        let(:error_name_input) { 'some_test_name' }
        let(:wrong_inputs) do
          [error_name_input, success_age_input, success_login_input, success_password_input]
        end

        context 'without small letter' do
          it {
            expect do
              account_service.create_account
            end.to output(/#{I18n.t("validation.name.first_letter")}/).to_stdout
          }
        end
      end

      context 'with login errors' do
        let(:error_login_input) { '' }
        let(:wrong_inputs) do
          [success_name_input, success_age_input, error_login_input, success_password_input]
        end

        before do
          stub_const('Modules::Constants::FILE_PATH', test_filename)
          allow(account_service).to receive(:gets).and_return(*wrong_inputs)
        end

        after do
          FileUtils.rm_rf(test_filename)
        end

        context 'when present' do
          it { expect { account_service.create_account }.to output(/#{I18n.t("validation.login.present")}/).to_stdout }
        end

        context 'when longer' do
          let(:error_login_length_input) { 'A' * (Modules::Constants::LOGIN_MIN_LENGTH - 1) }
          let(:wrong_inputs) do
            [success_name_input, success_age_input, error_login_length_input, success_password_input]
          end

          before do
            stub_const('Modules::Constants::FILE_PATH', test_filename)
            allow(account_service).to receive(:gets).and_return(*wrong_inputs)
          end

          after do
            FileUtils.rm_rf(test_filename)
          end

          it do
            expect { account_service.create_account }.to output(/#{I18n.t("validation.login.longer")}/).to_stdout
          end
        end

        context 'when shorter' do
          let(:error_login_length_input) { 'A' * (Modules::Constants::LOGIN_MAX_LENGTH + 1) }
          let(:wrong_inputs) do
            [success_name_input, success_age_input, error_login_length_input, success_password_input]
          end

          before do
            stub_const('Modules::Constants::FILE_PATH', test_filename)
            allow(account_service).to receive(:gets).and_return(*wrong_inputs)
          end

          after do
            FileUtils.rm_rf(test_filename)
          end

          it { expect { account_service.create_account }.to output(/#{I18n.t("validation.login.shorter")}/).to_stdout }
        end

        context 'when exists' do
          let(:error_login_input) { '' }
          let(:wrong_inputs) do
            [success_name_input, success_age_input, error_login_input, success_password_input]
          end
          let(:correct_account) do
            Entities::Account.new(name: success_name_input,
                                  age: success_age_input,
                                  login: error_login_input,
                                  password: success_password_input)
          end

          before do
            stub_const('Modules::Constants::FILE_PATH', test_filename)
            new_accounts_save(correct_account)
            allow(account_service).to receive(:gets).and_return(*wrong_inputs)
          end

          after do
            FileUtils.rm_rf(test_filename)
          end

          it { expect { account_service.create_account }.to output(/#{I18n.t("validation.login.exists")}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:error_age_input) { '22' }
        let(:wrong_inputs) do
          [success_name_input, error_age_input, success_login_input, success_password_input]
        end

        before do
          stub_const('Modules::Constants::FILE_PATH', test_filename)
          allow(account_service).to receive(:gets).and_return(*wrong_inputs)
        end

        after do
          FileUtils.rm_rf(test_filename)
        end

        context 'with length minimum' do
          it { expect { account_service.create_account }.to output(/#{I18n.t("validation.age.length")}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_age_input) { (Modules::Constants::AGE_MAX_LENGTH + 1).to_s }
          let(:wrong_inputs) do
            [success_name_input, error_age_input, success_login_input, success_password_input]
          end

          before do
            stub_const('Modules::Constants::FILE_PATH', test_filename)
            allow(account_service).to receive(:gets).and_return(*wrong_inputs)
          end

          after do
            FileUtils.rm_rf(test_filename)
          end

          it { expect { account_service.create_account }.to output(/#{I18n.t("validation.age.length")}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:wrong_inputs) do
          [success_name_input, success_age_input, success_login_input, error_password_input]
        end

        before do
          stub_const('Modules::Constants::FILE_PATH', test_filename)
          allow(account_service).to receive(:gets).and_return(*wrong_inputs)
        end

        after do
          FileUtils.rm_rf(test_filename)
        end

        context 'when absent' do
          let(:error_password_input) { '' }

          it {
            expect do
              account_service.create_account
            end.to output(/#{I18n.t("validation.password.present")}/).to_stdout
          }
        end

        context 'when longer' do
          let(:error_password_input) { 'E' * (Modules::Constants::PASSWORD_MIN_LENGTH - 1) }

          it {
            expect do
              account_service.create_account
            end.to output(/#{I18n.t("validation.password.longer")}/).to_stdout
          }
        end

        context 'when shorter' do
          let(:error_password_input) { 'E' * (Modules::Constants::PASSWORD_MAX_LENGTH + 1) }

          it {
            expect do
              account_service.create_account
            end.to output(/#{I18n.t("validation.password.shorter")}/).to_stdout
          }
        end
      end
    end
  end

  describe '#load' do
    context 'with active accounts' do
      let(:login) { 'fafafa' }
      let(:password) { '123123' }
      let(:success_name_input) { Faker::Name.first_name }
      let(:success_age_input) { Faker::Number.between(from: Modules::Constants::AGE_MIN_LENGTH, to: Modules::Constants::AGE_MAX_LENGTH).to_s }
      let(:correct_account) do
        Entities::Account.new(name: success_name_input,
                              age: success_age_input,
                              login: login,
                              password: password)
      end

      before do
        new_accounts_save(correct_account)
        allow(account_service).to receive(:loop).and_yield
        allow(account_service).to receive(:gets).and_return(login, password)
      end

      context 'with correct outout' do
        it do
          expect(I18n).to receive(:t).with('input.login')
          expect(I18n).to receive(:t).with('input.password')
          account_service.load_account
        end
      end

      context 'when account doesn\t exists' do
        let(:login) { 'fgfgfg' }
        let(:password) { '123123' }
        let(:expected_message) { message_for_login + message_for_password }
        let(:message_for_login) { I18n.t('input.login') }
        let(:message_for_password) { I18n.t('input.password') }

        it { expect { account_service.load_account }.to output(expected_message).to_stdout }
      end
    end
  end
end
