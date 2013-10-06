class Node < ActiveRecord::Base
  attr_accessible :name, :node_type
  validates :name, uniqueness: true
  has_many :location_marginal_prices
  has_many :calculations
  scope :name_is, ->(v) { where( "name = ?", v ) } 
end
