class Spree::Admin::AdvancedReportOverviewController < Spree::Admin::BaseController
  def index
    @reports = Spree::Admin::ReportsController::ADVANCED_REPORTS
    @products = Spree::Product.all
    @taxons = Spree::Taxon.all
    if defined?(MultiDomainExtension)
      @stores = Store.all
    end
    @report = Spree::AdvancedReport::IncrementReport::Revenue.new({ :search => {} })
    @top_products_report = Spree::AdvancedReport::TopReport::TopProducts.new({ :search => {} }, 5)
    @top_customers_report = Spree::AdvancedReport::TopReport::TopCustomers.new({ :search => {} }, 5)
    @top_customers_report.ruportdata.remove_column("Units")

    @subscriptions = Spree::AccountSubscription.all
    @subscription_seats = Spree::SubscriptionSeat.all

    puts "ADVANCED REPORT!!!!!"

    # From overview_dashboard, Cleanup eventually
    orders = Spree::Order.find(:all, :order => "completed_at DESC", :limit => 10, :include => :line_items, :conditions => "completed_at is not null")
    @last_orders = orders.inject([]) { |arr, o| arr << [o.bill_address.firstname, o.line_items.sum(:quantity), o.total, o.number]; arr }
    @best_taxons =  Spree::Taxon.connection.select_rows("select t.name, count(li.quantity) from spree_line_items li inner join spree_variants v on
           li.variant_id = v.id inner join spree_products p on v.product_id = p.id inner join spree_products_taxons pt on p.id = pt.product_id
           inner join spree_taxons t on pt.taxon_id = t.id where t.taxonomy_id = #{Spree::Taxonomy.last.id} group by t.name order by count(li.quantity) desc limit 5;")
  end
end
