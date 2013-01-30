class Holiday < ActiveRecord::Base
  attr_accessible :occurance, :name
  validates :occurance, uniqueness: true, presence: true
  validates :name, presence: true

end
