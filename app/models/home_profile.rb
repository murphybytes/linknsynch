class HomeProfile < ActiveRecord::Base
  attr_accessible :base_temperature, :btu_factor, :description, :home_count, :name, :user_id
end
