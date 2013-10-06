require 'test_helper'


class CalculationTest < ActiveSupport::TestCase

  # test "should associate multiple thermal storage profiles with calculation" do
  #   t = ThermalStorageProfile.all
  # end 

  test "should allow same calculation name for different users" do
    users = User.all
    assert users.size >= 2
    calc = Calculation.new
    calc.name = 'Test'
    calc.user = users.first
    calc.node = Node.all.first
    calc.set_meta = SetMeta.all.first

    assert calc.save
    calc = Calculation.new
    calc.name = 'Test'
    calc.user = users.last
    calc.node = Node.all.first
    calc.set_meta = SetMeta.all.first

    assert calc.save
  end

  test "should not allow calculations with duplicate names for a user" do
    user = User.all.first
    calc = Calculation.new
    calc.name = 'Test'
    calc.user = user
    calc.node = Node.all.first
    calc.set_meta = SetMeta.all.first

    assert calc.save, 'save should succeed'
    calc = Calculation.new
    calc.name = 'Test'
    calc.user = user
    calc.node = Node.all.first
    calc.set_meta = SetMeta.all.first

    refute calc.save, 'Validation should fail when saving calc with duplicate name'
    
  end

  test "validates presence of user" do
    calc = Calculation.new
    refute calc.save 
  end

  test 'has and belongs to thermal storage profiles' do
    calc = Calculation.new
    calc.user = User.all.first
    calc.name = 'TestTStorage'
    calc.node = Node.all.first
    calc.set_meta = SetMeta.all.first

    ts = ThermalStorageProfile.all
    ts.each do |t|
      calc.thermal_storage_profiles << t
    end
    assert calc.save
    calcs = Calculation.name_is( 'TestTStorage' ).user_is( calc.user ) 
    assert_equal 1, calcs.size
    
    assert_equal ts.size, calcs.first.thermal_storage_profiles.size
    
    ThermalStorageProfile.all.each do |t|
      assert_equal 'TestTStorage', t.calculations.first.name
    end
    
  
  end

  test "has and belongs to many home profiles" do
    calc = Calculation.new 
    calc.user = User.all.first
    calc.name = 'TestHProfile'
    calc.node = Node.all.first
    calc.set_meta = SetMeta.all.first
    HomeProfile.all.each do |hp|
      calc.home_profiles << hp
    end
    assert calc.save, 'save with home profiles'
    calcs = Calculation.name_is( calc.name ).user_is( calc.user ) 
    assert_equal 1, calcs.size
    assert_equal HomeProfile.count, calcs.first.home_profiles.size
    HomeProfile.all.each do |hp|
      assert_equal 'TestHProfile', hp.calculations.first.name 
    end
  end

end
