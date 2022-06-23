module Entities
  module Cards
    class VirtualCard < BasicCard
      def type
        VIRTUAL_CARD
      end

      def number
        @number ||= generate_card_number
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
