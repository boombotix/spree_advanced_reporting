Spree::Order.class_eval do
  has_many :valid_payments,
    -> { where.not(state: %w(failed invalid)) },
    class_name: 'Spree::Payment',
    foreign_key: :order_id
end
