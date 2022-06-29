# frozen_string_literal: true

require 'yaml'
require 'i18n'
require 'pry'

require_relative 'config/config'

require_relative 'entities/cards/basic_card'
require_relative 'entities/cards/capitalist_card'
require_relative 'entities/cards/usual_card'
require_relative 'entities/cards/virtual_card'

require_relative 'modules/constants'
require_relative 'modules/validation'
require_relative 'modules/account_validate'
require_relative 'modules/data_loader'
require_relative 'modules/console_helper'

require_relative 'modules/money_operations'
require_relative 'modules/commands/transaction_commands'
require_relative 'modules/commands/card_commands'
require_relative 'modules/commands/account_commands'

require_relative 'entities/account'
require_relative 'entities/console'
