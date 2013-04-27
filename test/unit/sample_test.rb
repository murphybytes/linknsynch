require 'test_helper'

class SampleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "sample by month query" do
    result =  Sample.samples_for_month( 1, 2011, 1 )
    assert_not_nil result
    assert_equal result.count, 744
    assert_equal result.first.sample_time.day, 1
    assert_equal result.first.sample_time.month, 1
    assert_equal result.first.sample_time.year, 2011
    assert_equal result.last.sample_time.day, 31
    assert_equal result.last.sample_time.month, 1
    assert_equal result.last.sample_time.year, 2011
  end
end
