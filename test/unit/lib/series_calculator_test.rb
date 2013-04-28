require 'test_helper'

class SeriesCalculatorTest < ActiveSupport::TestCase

  def setup
    @@set ||= SetMeta.where( :name => 'MyString' ).first
    @home_profile ||= HomeProfile.where( :name => 'TestHomeProfile' ).first    
  end

  
  test "Verify Generation Duration Data" do
    calculator = PQR::SeriesCalculator.new( samples: @@set.samples )
   
    series = calculator.get_generation_series
    assert_equal series.count, 11
    assert_equal sum_series( series ), 744  
  end

  test "Verify Demand Duration Data" do
    calculator = PQR::SeriesCalculator.new( samples: @@set.samples, home_profile: @home_profile )
   
    series = calculator.get_demand_series
    assert_equal series.count, 11
  end

  def sum_series( series )
    result = 0
    series.each { |v| result += v.first }
    result
  end

end
