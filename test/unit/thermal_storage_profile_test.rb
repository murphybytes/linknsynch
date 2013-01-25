require 'test_helper'

class ThermalStorageProfilesTest < ActiveSupport::TestCase
  test "should not save thermal profile without name" do
    tp = ThermalStorageProfile.new
    assert !tp.save
  end

  test "should not save thermal profile unless capacity is present and is a number" do 
    tp = ThermalStorageProfile.new
    tp.name = 'unique 1'
    tp.charge_rate = 1.0
    tp.units = 1000
    tp.usage = 1.0
    tp.base_threshold = 10.0

    assert !tp.save

    tp.capacity = 'x'
    assert !tp.save

    tp.capacity = 23.0
    
    assert tp.save
  end 

  test "storage should be the same as capacity" do 
    tp = ThermalStorageProfile.new
    tp.capacity = 23.0
    tp.charge_rate = 1.0
    tp.units = 1000
    tp.usage = 1.0
    tp.base_threshold = 10.0


    tp.name = 'unique 2'
    assert tp.save
    assert_equal tp.capacity, tp.storage
  end


end
