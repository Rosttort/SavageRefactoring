# frozen_string_literal: true

RSpec.describe Entities::Account do
  include Modules::DataLoader
  include Modules::ConsoleHelper
  subject(:correct_account) do
    described_class.new(name: success_name_input,
                        age: success_age_input,
                        login: correct_login,
                        password: success_password_input)
  end

  let(:correct_login) { Faker::Internet.username(specifier: 4..20) }
  let(:success_name_input) { Faker::Name.first_name }
  let(:success_age_input) { Faker::Number.between(from: 23, to: 90).to_s }
  let(:success_password_input) { Faker::Internet.password(min_length: 6, max_length: 30) }
  let(:test_filename) { 'spec/fixtures/test_account.yml' }

  describe '#destroy_account' do
    let(:success_input) { Modules::Constants::AGREE_COMMAND }
    let(:file_accounts) { YAML.load_file(test_filename) }

    before do
      allow(correct_account).to receive_message_chain(:gets, :chomp) { success_input }
      stub_const('Modules::Constants::FILE_PATH', test_filename)
      allow(correct_account).to receive(:exit)
      new_accounts_save(correct_account)
      correct_account.destroy_account(correct_account)
    end

    after do
      FileUtils.rm_rf(test_filename)
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        expect(File.exist?(test_filename)).to be true
        expect(file_accounts.size).to be 0
      end

      it 'doesnt delete account' do
        expect(File.exist?(test_filename)).to be true
      end
    end
  end
end
