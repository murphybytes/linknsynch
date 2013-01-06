class SetMeta < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :samples, :autosave => true, :dependent => :delete_all
  belongs_to :user
  validates :name, :uniqueness => true
end
