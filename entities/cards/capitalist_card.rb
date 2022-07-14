# frozen_string_literal: true

module Entities
  module Cards
    class CapitalistCard < BasicCard
      attr_reader :type

      def initialize
        @type = CAPITALIST_CARD
        super
      end

      private

      def start_balance
        100.00
      end

      def withdraw_percent
        4
      end

      def put_fixed
        10
      end

      def sender_percent
        10
      end
    end
  end
end
