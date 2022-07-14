# frozen_string_literal: true

module Entities
  module Cards
    class VirtualCard < BasicCard
      attr_reader :type

      def initialize
        @type = VIRTUAL_CARD
        super
      end

      private

      def start_balance
        150.00
      end

      def withdraw_percent
        88
      end

      def put_fixed
        1
      end

      def sender_fixed
        1
      end
    end
  end
end
