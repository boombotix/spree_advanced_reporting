class Spree::AdvancedReport::DailyDetailsReport < Spree::AdvancedReport::IncrementReport
  attr_accessor :date, :products, :shipments, :tax_adjustments, :price_adjustments, :other_adjustments, :orders, :payments

  def name
    "Detailed Units Sold"
  end

  def column
    "Detailed Units"
  end

  def description
    "Total units sold in orders, a sum of the item quantities per order or per item"
  end

  def initialize(params)
    super(params)

    results = details_for_date(date)
    date = params[:date] ? Date.parse(params[:date]) : Date.today

    self.date = date

    # Update the accessor values
    results.each{|k,v| self.send("#{k}=", v)}
  end

  def details_for_date(date)
    date = params[:date] ? Date.parse(params[:date]) : Date.today
    conditions = {updated_at: date.beginning_of_day..date.end_of_day, state: 'completed'}

    payments = Spree::Payment.joins(:order).where(conditions).where('spree_orders.completed_at is not null').includes(source: [], order: [:shipments, :adjustments])
    orders = payments.collect(&:order).uniq

    shipments = orders.collect(&:shipments).flatten

    adjustment_ids = orders.collect(&:adjustments).flatten.collect(&:id)
    tax_adjustments = Spree::Adjustment.tax.where(id: adjustment_ids)
    price_adjustments = Spree::Adjustment.price.where(id: adjustment_ids)
    other_adjustments = Spree::Adjustment.where(id: adjustment_ids) - tax_adjustments - price_adjustments - shipments.collect(&:adjustments)

#    adjustments = orders.collect(&:adjustments).flatten.select{|a| a.source_type != 'Spree::Shipment'}


    line_items = orders.collect(&:line_items).flatten

    products = line_items.reduce({}) do |memo, item|
      memo[item.variant] ||= {amount: 0, quantity: 0}
      memo[item.variant][:amount] += item.amount
      memo[item.variant][:quantity] += item.quantity
      memo
    end

    {products: products, shipments: shipments, tax_adjustments: tax_adjustments, price_adjustments: price_adjustments, other_adjustments: other_adjustments, orders: orders, payments: payments}
  end


  # This is a placeholder for logic that determines how many items in an order were actually shipped.
  # It may never be used again

  def items_shipped_from_an_order
    # For each order, determine how many
    items = {}
    orders.each do |o|
      shipped_variants = o.inventory_units.collect{|i| i.variant}
      o.line_items.each do |i|
        variant = i.variant
        quantity = shipped_variants.count(variant)
        items[variant] ||= {count: 0, price: 0}
        items[variant][:count] += 1
        items[variant][:price] += i.price * quantity
      end
    end

    [items, shipments, adjustments]
  end

end
