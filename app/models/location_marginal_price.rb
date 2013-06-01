class LocationMarginalPrice < ActiveRecord::Base
  attr_accessible :node_id, :period, :value
  validates :period, :uniqueness => { :scope => :node_id }
  belongs_to :node

end
