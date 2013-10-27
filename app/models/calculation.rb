


class Calculation < ActiveRecord::Base
  attr_accessible :name, :description, :set_meta, :thermal_storage_profiles, :home_profiles
  validates :name, uniqueness: { scope: :user_id, message: 'Calculation must have unique name' } 
  validates :user, presence: true
  validates :set_meta, presence: true
  validates :node, presence: true
  belongs_to :user
  belongs_to :set_meta
  belongs_to :node
  has_and_belongs_to_many  :thermal_storage_profiles
  has_and_belongs_to_many :home_profiles
  scope :name_is, ->( v ) { where( "name = ?", v ) }
  scope :user_is, ->( u ) { where( "user_id = ?", u.id ) }
end
