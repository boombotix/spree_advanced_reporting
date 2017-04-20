class Spree::AdvancedReport::SubscriptionSeatReport::Units < Spree::AdvancedReport::IncrementReport
  def name
    "Subscriptions Seats Activated"
  end

  def column
    "Units"
  end

  def description
    "Total Subscription Seats Being Used"
  end

  def initialize(params)
    super(params)
    self.total = 0
    self.subscription_seats.each do |seat|
      account_subscription = Spree::AccountSubscription.find_by(:id => seat.account_subscription_id)
      date = {}
      if account_subscription.present?
        INCREMENTS.each do |type|
          date[type] = get_bucket(type, account_subscription.start_datetime)
          data[type][date[type]] ||= {
            :value => 0,
            :display => get_display(type, account_subscription.start_datetime),
          }
        end
        units = 1
        INCREMENTS.each { |type| data[type][date[type]][:value] += units }
        self.total += units
      end

    end

    generate_ruport_data
  end
end
