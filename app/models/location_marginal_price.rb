class LocationMarginalPrice < ActiveRecord::Base
  attr_accessible :node_id, :period, :value
  validates :period, :uniqueness => { :scope => :node_id }
  belongs_to :node

  def self.get_prices_for_node_in_range( node_name, period_start, period_end )
    node = Node.first( :conditions => { :name => node_name } )
    raise "Node named #{node_name} does not exist" if node.nil? 
    LocationMarginalPrice.where( "period >= :period_start AND period < :period_end AND node_id = :node_id", 
                                 { :period_start => period_start, :period_end => period_end, :node_id => node.id } )
  end

end
