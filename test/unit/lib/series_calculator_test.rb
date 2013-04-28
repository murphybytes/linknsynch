require 'test_helper'

class SeriesCalculatorTest < ActiveSupport::TestCase

  def setup
    @@set ||= SetMeta.where( :name => 'MyString' ).first    
  end

  
  test "Verify Generation Duration Data" do
    calculator = PQR::SeriesCalculator.new( samples: @@set.samples )
   
    series = calculator.get_generation_series
    assert_equal series.count, 10
    assert_equal sum_series( series ), 744  
  end

  def sum_series( series )
    result = 0
    series.each { |v| result += v.first }
    result
  end

end
