require 'test_helper'

class LocationMarginalPriceTest < ActiveSupport::TestCase
  test "fetch prices for a node in a date range" do
    prices = LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', DateTime.new( 2011, 2, 1 ), DateTime.new( 2011, 3, 1) )
    assert_equal 672, prices.count 
  end

  test "fetch prices for node for a year" do
    start_date = DateTime. parse( "2011-01-01 00:00:00 UTC" )
    end_date = DateTime. parse( "2012-01-01 00:00:00 UTC" )
    prices = LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', start_date, end_date )

    assert_equal 8759, prices.count
  end
end
