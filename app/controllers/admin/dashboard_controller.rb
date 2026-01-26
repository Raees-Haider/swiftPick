module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @orders = Order.includes(:order_items, :user).order(created_at: :desc)
      
      @total_sales = @orders.count
      @total_revenue = @orders.sum(:total_amount) || 0
      @total_customers = User.where(role: 'customer').count
      @total_products = Product.where(active: true).count
      
      @sales_data = get_sales_data_by_day(30)
      
      @revenue_data = get_revenue_data_by_day(30)
      
      @monthly_sales_data = get_sales_data_by_month(12)
      
      @monthly_revenue_data = get_revenue_data_by_month(12)
    end
    
    private
    
    def get_sales_data_by_day(days)
      data = {}
      days.times do |i|
        date = i.days.ago.beginning_of_day
        count = Order.where(created_at: date..date.end_of_day).count
        data[date.strftime('%Y-%m-%d')] = count
      end
      data.sort_by { |k, v| k }.to_h
    end
    
    def get_revenue_data_by_day(days)
      data = {}
      days.times do |i|
        date = i.days.ago.beginning_of_day
        revenue = Order.where(created_at: date..date.end_of_day).sum(:total_amount) || 0
        data[date.strftime('%Y-%m-%d')] = revenue.to_f
      end
      data.sort_by { |k, v| k }.to_h
    end
    
    def get_sales_data_by_month(months)
      data = {}
      months.times do |i|
        date = i.months.ago.beginning_of_month
        count = Order.where(created_at: date..date.end_of_month).count
        data[date.strftime('%Y-%m')] = count
      end
      data.sort_by { |k, v| k }.to_h
    end
    
    def get_revenue_data_by_month(months)
      data = {}
      months.times do |i|
        date = i.months.ago.beginning_of_month
        revenue = Order.where(created_at: date..date.end_of_month).sum(:total_amount) || 0
        data[date.strftime('%Y-%m')] = revenue.to_f
      end
      data.sort_by { |k, v| k }.to_h
    end
  end
end
