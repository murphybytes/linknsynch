require 'test_helper'

class UtilsTest < ActiveSupport::TestCase
  
  test "should parse integer month, day, year from string date of m/d/yyyy" do
    month,day,year = PQR::Utils.get_month_day_year( "3/4/2011\n" )
    assert_equal month, 3
    assert_equal day, 4
    assert_equal year, 2011
    
  end

  test "should detect if a date is a holiday" do
    assert PQR::Utils.holiday?( 2012, 12, 25 ) 
  end

  test "should indicate holiday is off peak" do 
    assert  !PQR::Utils.is_peak?( Date.new( 2012, 12, 25 ) )
  end

  test "should flag weekday during day as on peak" do
    test_date = DateTime.new( 2012, 11, 13, 12 )
    assert PQR::Utils.is_peak?( test_date ) 
  end

  test "should flag weekday after 11 PM as off peak" do 
    test_date = DateTime.new( 2012, 11,13, 23, 30, 0, '-6' )
    assert !PQR::Utils.is_peak?( test_date ) 
  end

  test "should flag weekday before 11 PM but after 7 PM as on peak" do 
    test_date = DateTime.new( 2012, 11,13, 22, 59, 0, '-6' )
    assert PQR::Utils.is_peak?( test_date ) 
  end

  test "should flag weekend as off peak" do 
    test_date = DateTime.new( 2012, 11, 10, 12 ) 
    PQR::Utils.is_peak?( test_date ) 
  end

  test "should calculate kw required for heated water use" do
    kwh = PQR::Utils.gph_to_kwh( 54, 60 )
    assert_equal 8, kwh.to_i
  end

  test "should calculate energy stored in water at particular temp delta from ambient temp" do 
    kwh = PQR::Utils.calc_energy_stored( 264.170083266, 68, 194 )
    assert_equal 81.7, kwh.round(1)
  end
  

end
