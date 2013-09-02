require 'test_helper'

class InterruptableModelTest < ActiveSupport::TestCase

  def setup
    @sample = Sample.where( set_meta_id: 2, sample_time: DateTime.new( 2011, 1, 31, 23 )).first
    begin_date, end_date =  [DateTime. parse( "2011-01-01 00:00:00" ), DateTime. parse( "2012-02-01 00:00:00" )]     
    @prices ||= LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', begin_date, end_date )
    @thermal_storage ||= PQR::ThermalStorageModel.new( ThermalStorageProfile.all, @prices )
  end


  test "verify total energy needed is correctly calculated" do
    im = PQR::InterruptableModel.new( HomeProfile.all, @prices, PQR::ThermalStorageModel.new( ThermalStorageProfile.all, @prices ))
    im.update( 10000, 8000, @sample )
    assert_equal im.total_energy_needed.round( 3), 5330.784 
  end

  test "verify energy used is correct when we have excess energy available" do
    im = PQR::InterruptableModel.new( HomeProfile.all, @prices, PQR::ThermalStorageModel.new( ThermalStorageProfile.all, @prices ))

    available_energy, available_energy_ls = im.update( 10000, 8000, @sample)
    assert_equal 5330.784, im.total_energy_used.round(3)
    assert_equal 5330.784, im.total_energy_used_ls.round(3)
    assert_equal 0, im.total_load_unserved 
    assert_equal 0, im.total_load_unserved_ls
    assert_equal 4669.216, available_energy.round(3)
    assert_equal 2669.216, available_energy_ls.round(3)
  end

  test "verify that energy used is correct when we don't have excess energy available" do
    im = PQR::InterruptableModel.new( HomeProfile.all, @prices, PQR::ThermalStorageModel.new( ThermalStorageProfile.all, @prices ))

    available_energy, available_energy_ls = im.update( 5000, 4000, @sample)
    assert_equal 5000.000, im.total_energy_used.round(3)
    assert_equal im.total_energy_used_ls.round(3), 5330.784
    assert_equal 330.784, im.total_load_unserved.round(3) 
    assert_equal im.total_load_unserved_ls.round(3), 0.0
    assert_equal 0, available_energy
    assert_equal 0, available_energy_ls
  end


end
