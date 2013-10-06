class HomeProfile < ActiveRecord::Base
  attr_accessible :base_temperature, :thermostat_temperature, :btu_factor, :description, :home_count, :name, :user_id
  has_and_belongs_to_many :calculations
end
