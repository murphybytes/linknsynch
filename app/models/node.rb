class Node < ActiveRecord::Base
  attr_accessible :name, :node_type
  validates :name, uniqueness: true
  has_many :location_marginal_prices
end
