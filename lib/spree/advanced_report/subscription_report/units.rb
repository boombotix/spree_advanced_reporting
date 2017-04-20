class Spree::AdvancedReport::SubscriptionReport::Units < Spree::AdvancedReport::IncrementReport
  def name
    "Subscriptions Seats Sold"
  end

  def column
    "Units"
  end

  def description
    "Total Subscription Seats sold in orders, a sum of the item quantities per order or per item"
  end

  def initialize(params)
    super(params)
    self.total = 0
    self.subscriptions.each do |subscription|
      date = {}
      INCREMENTS.each do |type|
        date[type] = get_bucket(type, subscription.start_datetime)
        data[type][date[type]] ||= {
          :value => 0,
          :display => get_display(type, subscription.start_datetime),
        }
      end
      units = subscription.num_seats
      INCREMENTS.each { |type| data[type][date[type]][:value] += units }
      self.total += units
    end

    generate_ruport_data
  end
end
