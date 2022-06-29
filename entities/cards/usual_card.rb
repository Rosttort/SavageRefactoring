# frozen_string_literal: true

module Entities
  module Cards
    class UsualCard < BasicCard
      attr_reader :type

      def initialize
        @type = USUAL_CARD
        super
      end

      private

      def start_balance
        50.00
      end

      def withdraw_percent
        5
      end

      def put_percent
        2
      end

      def sender_fixed
        20
      end
    end
  end
end
