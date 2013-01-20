require 'test_helper'


class ThermalStorageModelTest < ActiveSupport::TestCase
  def setup
    water_heaters = ThermalStorageProfile.where( name: 'WaterHeaters' ).first
    slab_heaters = ThermalStorageProfile.where( name: 'SlabHeaters' ).first
    @model ||= PQR::ThermalStorageModel.new( water_heaters, slab_heaters )
  end

  test "Verify Unit Count" do
    assert_equal 300, @model.unit_count
  end

  test "Should not take charge when fully charged" do
    charge_available = 1800
    assert_equal 0, @model.charge( charge_available ) 
    assert_equal 1800, charge_available 
  end

  test "Should apply fractional charge when there is more charge than capacity" do
    charge = 1800
    expected = 300
    @model.reduce_available( expected )
    assert_equal @model.total_storage, @model.total_capacity - 300
    assert_equal expected, @model.charge( charge ) 
    assert_equal @model.total_storage, @model.total_capacity    
  end

  test "Should not exceed max charge rate" do
    charge = 1500
    expected = 1200
    @model.reduce_available( charge ) 
    assert_equal expected, @model.charge( charge )
  end

  test "Should reduce storage by the correct amount" do
    @model.apply_normal_usage
    assert_equal 3150, @model.total_storage
  end

  test "Should correctly calculate available kws" do
    assert_equal 1200, @model.get_available
  end

  

end
