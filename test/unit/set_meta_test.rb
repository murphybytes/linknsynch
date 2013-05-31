require 'test_helper'

class SetMetaTest < ActiveSupport::TestCase
  test "get first sample date" do
    sm = SetMeta.find( 1 )
    expected = DateTime.parse( "2011-01-01 00:00:00" )
    assert_equal expected , sm.get_first_sample_date
  end

  test "get ceiling sample date" do
    sm = SetMeta.find( 1 )
    expected = DateTime.parse( "2012-01-01 00:00:00" )
    assert_equal expected, sm.get_ceiling_sample_date 
  end



  
end
