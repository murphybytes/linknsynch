require 'test_helper'


class CalculatorTest < ActiveSupport::TestCase
  def setup
    @@set ||= SetMeta.where( :name => 'TestSample' ).first
  end

  test "Verify Sample Count" do
    assert_equal 8760, @@set.samples.size, "sample count"
  end

  test "calculator" do
    calculator = PQR::Calculator.new( samples: @@set.samples )
    calculator.run
    assert_equal 8760 * 10000, calculator.total_kw_generated
  end

end
