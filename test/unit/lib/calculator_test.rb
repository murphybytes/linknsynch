require 'test_helper'


class CalculatorTest < ActiveSupport::TestCase
  def setup
    @@set ||= SetMeta.where( :name => 'TestSample' ).first
    @home_profile ||= HomeProfile.where( :name => 'TestHomeProfile' ).first

    @water_heaters ||= ThermalStorageProfile.where( name: 'WaterHeaters' ).first
    @slab_heaters ||= ThermalStorageProfile.where( name: 'SlabHeaters' ).first
    @model ||= PQR::ThermalStorageModel.new( @water_heaters, @slab_heaters )
    
    @calculator ||= PQR::Calculator.new( samples: @@set.samples, home_profile: @home_profile, thermal_storage_model: @model )
    @calculator.run

  end

  test "Verify Sample Count" do
    assert_equal 8760, @@set.samples.size, "sample count"
  end

  test "Verify Total KW Generation" do
    assert_equal 8760 * 10000, @calculator.total_kw_generated
  end

  test "Verify KW required for home heating" do
    assert_equal 36625624, @calculator.total_kw_required_for_heating    
  end

  test "Verify KW load unserved" do 
    assert_equal 0, @calculator.total_kw_load_unserved
  end
  

end
