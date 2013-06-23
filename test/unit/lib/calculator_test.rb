require 'test_helper'


class CalculatorTest < ActiveSupport::TestCase

  def setup
    @@set ||= SetMeta.where( :name => 'TestSample' ).first
    begin_date, end_date =  [DateTime. parse( "2011-01-01 00:00:00" ), DateTime. parse( "2012-01-01 00:00:00" )] 
    @home_profile ||= HomeProfile.where( :name => 'TestHomeProfile' ).first

    @water_heaters ||= ThermalStorageProfile.where( name: 'WaterHeaters' ).first
    @slab_heaters ||= ThermalStorageProfile.where( name: 'SlabHeaters' ).first
    @model ||= PQR::ThermalStorageModel.new( @water_heaters, @slab_heaters )
    @prices ||= LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', begin_date, end_date )
    @calculator ||= PQR::Calculator.new( prices: @prices, samples: @@set.samples, home_profile: @home_profile, thermal_storage_model: @model )
    @calculator.run

  end

  test "Verify Sample Count" do
    assert_equal 8760, @@set.samples.size, "sample count"
  end

  test "Verify Total KW Generation" do
    assert_equal 8760 * 100, @calculator.total_kw_generated
  end

  test "Verify Total MW Generation" do
    assert_equal 8760 * 0.1, @calculator.total_mw_generated
  end

  test "Verify Total Generation LMP" do
    assert_equal 876 * 10.10, @calculator.total_kw_generated_price.round( 1 )
  end 

  test "Verify KW required for home heating" do
    assert_equal 36625624, @calculator.total_kw_required_for_heating.round
  end

  test "Verify KW load unserved" do 
    assert_equal 35749624, @calculator.total_kw_load_unserved.round
  end

  test "Verify begin date" do 
    assert_equal "2011-01-01 00:00:00", @calculator.begin_time.strftime( "%Y-%m-%d %H:%M:%S" )
  end

  test "Verify end date" do
    assert_equal "2011-12-31 23:00:00", @calculator.end_time.strftime( "%Y-%m-%d %H:%M:%S" )
  end

  test "Verify month count" do
    assert_equal 12, @calculator.get_months.count
  end


  test "Verify date range" do
    months = @calculator.get_months
    assert_equal months.first.month, 1
    assert_equal months.first.year, 2011
    assert_equal months.last.month, 12
    assert_equal months.last.year, 2011
  end

  test "price of total generated kw" do
    expected = @calculator.total_kw_generated * ( 10.10 / 1000.0 )
    assert_equal expected, @calculator.total_kw_generated_price.round( 1 )
  end

end
