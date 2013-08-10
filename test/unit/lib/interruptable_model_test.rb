require 'test_helper'

class InterruptableModelTest < ActiveSupport::TestCase

  def setup
    @im = PQR::InterruptableModel.new( HomeProfile.all )
    @im.update_interruptables( 10, 8, Sample.where( set_meta_id: 2, sample_time: DateTime.new( 2011, 1, 31, 23 )).first)
  end

  test "verify total energy required is correctly calculated" do
    assert_equal 5330.784, @im.total_energy_needed.round( 3) 
  end



end
