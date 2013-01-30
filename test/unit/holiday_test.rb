require 'test_helper'

class HolidayTest < ActiveSupport::TestCase
  test "Create a new holiday" do
    Holiday.create!( name: 'test 1', occurance: '2012-12-26' )
    assert Holiday.exists?( name: 'test 1' )
  end
end
