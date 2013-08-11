require 'test_helper'

class InterruptableModelTest < ActiveSupport::TestCase

  def setup
    @sample = Sample.where( set_meta_id: 2, sample_time: DateTime.new( 2011, 1, 31, 23 )).first
  end


  test "verify total energy needed is correctly calculated" do
    im = PQR::InterruptableModel.new( HomeProfile.all )
    im.update_interruptables( 10000, 8000, @sample )
    assert_equal 5330.784, im.total_energy_needed.round( 3) 
  end

  test "verify energy used is correct when we have excess energy available" do
    im = PQR::InterruptableModel.new( HomeProfile.all )
    available_energy, available_energy_ls = im.update_interruptables( 10000, 8000, @sample)
    assert_equal 5330.784, im.total_energy_used.round(3)
    assert_equal 5330.784, im.total_energy_used_ls.round(3)
    assert_equal 0, im.total_load_unserved 
    assert_equal 0, im.total_load_unserved_ls
    assert_equal 4669.216, available_energy.round(3)
    assert_equal 2669.216, available_energy_ls.round(3)
  end

  test "verify that energy used is correct when we don't have excess energy available" do
    im = PQR::InterruptableModel.new( HomeProfile.all )
    available_energy, available_energy_ls = im.update_interruptables( 5000, 4000, @sample)
    assert_equal 5000.000, im.total_energy_used.round(3)
    assert_equal 4000.000, im.total_energy_used_ls.round(3)
    assert_equal 330.784, im.total_load_unserved.round(3) 
    assert_equal 1330.784, im.total_load_unserved_ls.round(3)
    assert_equal 0, available_energy
    assert_equal 0, available_energy_ls
  end


end
