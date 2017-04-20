class Spree::AdvancedReport::SubscriptionReport::Revenue < Spree::AdvancedReport::IncrementReport
  def name
    "Subscription Revenue"
  end

  def column
    "Revenue"
  end

  def description
    "The sum of subscription item prices, excluding shipping and tax"
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
      rev = subscription.num_seats * 99.0
      INCREMENTS.each { |type| data[type][date[type]][:value] += rev }
      self.total += rev
    end

    generate_ruport_data

    INCREMENTS.each { |type| ruportdata[type].replace_column("Revenue") { |r| "$%0.2f" % r["Revenue"] } }
  end

  def format_total
    '$' + ((self.total*100).round.to_f / 100).to_s
  end
end
