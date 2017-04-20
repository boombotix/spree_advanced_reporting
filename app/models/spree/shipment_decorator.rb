Spree::Shipment.class_eval do
  has_one :_selected_shipping_rate,
    -> { where(selected: true) },
    class_name: 'Spree::ShippingRate'
  has_one :selected_shipping_method,
    through: :_selected_shipping_rate,
    source: :shipping_method
end
