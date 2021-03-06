class OrdersController < ApplicationController
	skip_before_filter :authorize, :only => [:new, :create]

	def new
		@cart = current_cart
		if @cart.line_items.empty?
			redirect_to root_path, notice: 'Your Cart is Empty!'
			return
		end

		@order = Order.new

	end

	def create
		@order = Order.new(params[:order])
		@order.add_line_items_from_cart(current_cart)
		if @order.save
			Cart.destroy(session[:cart_id])
			session[:cart_id] = nil
			Notifier.order_received(@order).deliver
			redirect_to root_path, notice: 'Thank you for your Order' 
		else
			render 'new'
		end
	end

	def index
		@orders = Order.paginate :page=>params[:page], :order=>'created_at desc',:per_page => 10
	end

	def destroy
		Order.find(params[:id]).destroy
		redirect_to orders_path, notice: "Order deleted Successfully!"
	end

	def show
		@remove_item_drop = true
		@order = Order.find(params[:id])
	end
end
