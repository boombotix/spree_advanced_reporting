require 'advanced_reporting_hooks'

module Spree
  module AdvancedReporting


    class Engine < Rails::Engine
      config.autoload_paths += %W(#{config.root}/lib)
      def self.activate

        Dir.glob(File.join(File.dirname(__FILE__), "../config/locales/*.yml")).each do |c|
          I18n.load_path << File.expand_path(c)
        end

        Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator.rb")).each do |c|
          Rails.env.production? ? require(c) : load(c)
        end

        # Ruport::Controller::Table.formats.merge({ :flot => MyFlotFormatter })
        # if Mime::Type.lookup_by_extension(:pdf) != 'application/pdf'
        #   Mime::Type.register('application/pdf', :pdf)
        # end

      end

      config.to_prepare &method(:activate).to_proc
    end
  end
end

