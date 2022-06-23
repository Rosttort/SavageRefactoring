module Entities
  module Cards
    class CapitalistCard < BasicCard
      def type
        CAPITALIST_CARD
      end

      def number
        @number ||= generate_card_number
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
