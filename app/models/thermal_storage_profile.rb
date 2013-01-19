class ThermalStorageProfile < ActiveRecord::Base
  attr_accessible :base_threshold, :capacity, :charge_rate, :description, :name, :storage, :units, :usage, :user_id
  validates :name, :uniqueness => true
  belongs_to :user

end
