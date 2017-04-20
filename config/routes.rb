Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :reports, only: [] do
      collection do
        get :revenue
        get :count
        get :units
        get :profit
        get :subscriptions
        get :subscription_seats_in_use
        get :subscription_revenue
        get :top_customers
        get :top_products
        get :geo_revenue
        get :geo_units
        get :geo_profit
        get :daily_details
        get :order_details
      end
    end
  end
end
