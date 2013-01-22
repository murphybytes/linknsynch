require 'test_helper'

class UtilsTest < ActiveSupport::TestCase

  test "should detect if a date is a holiday" do
    assert PQR::Utils.holiday?( 2012, 12, 25 ) 
  end

  test "should indicate holiday is off peak" do 
    assert  !PQR::Utils.is_peak?( Date.new( 2012, 12, 25 ) )
  end

  

end
