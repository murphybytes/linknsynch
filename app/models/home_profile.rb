class HomeProfiles < ActiveRecord::Base
  attr_accessible :base_temperature, :btu_required, :description, :home_count, :name, :user_id
end
