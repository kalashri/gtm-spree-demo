# app/models/spree/promotion/rules/order_quantity.rb
# A rule to apply to an order having quantity 'greater than', 'less than',
# 'greater than or equal to' or 'less than or equal to'

module Spree
  class Promotion
    module Rules
      class OrderQuantity < Spree::PromotionRule
        preference :quantity_min, :decimal, default: 10
        preference :operator_min, :string, default: '>'
        preference :quantity_max, :decimal, default: 100
        preference :operator_max, :string, default: '<'

        OPERATORS_MIN = ['gt', 'gte']
        OPERATORS_MAX = ['lt', 'lte']

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          order_quantity = order.quantity

          lower_limit_condition = order_quantity.send(preferred_operator_min == 'gte' ? :>= : :>, preferred_quantity_min)
          upper_limit_condition = order_quantity.send(preferred_operator_max == 'lte' ? :<= : :<, preferred_quantity_max)

          eligibility_errors.add(:base, ineligible_message_max) unless upper_limit_condition
          eligibility_errors.add(:base, ineligible_message_min) unless lower_limit_condition

          eligibility_errors.empty?
        end

        private

        def ineligible_message_max
          if preferred_operator_max == 'gte'
            eligibility_error_message(:order_quantity_more_than_or_equal, amount: preferred_quantity_max)
          else
            eligibility_error_message(:order_quantity_more_than, amount: preferred_quantity_max)
          end
        end

        def ineligible_message_min
          if preferred_operator_min == 'gte'
            eligibility_error_message(:order_quantity_less_than, amount: preferred_quantity_min)
          else
            eligibility_error_message(:order_quantity_less_than_or_equal, amount: preferred_quantity_min)
          end
        end
      end
    end
  end
end
