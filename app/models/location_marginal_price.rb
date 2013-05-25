class LocationMarginalPrice < ActiveRecord::Base
  attr_accessible :node_id, :period, :value

  belongs_to :node

end
