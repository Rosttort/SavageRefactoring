module Entities
  module Cards
    class UsualCard < BasicCard
      def type
        USUAL_CARD
      end

      def number
        @number ||= generate_card_number
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
