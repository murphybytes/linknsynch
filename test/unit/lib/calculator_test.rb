require 'test_helper'
$: << Dir.pwd
require 'lib/pqr/calculator'

class CalculatorTest < ActiveSupport::TestCase
  test "calculator" do
    calculator = PQR::Calculator.new( {} )
    calculator.run
    assert calculator.total_kw_generated > 0
  end

end
