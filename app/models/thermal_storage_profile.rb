class ThermalStorageProfile < ActiveRecord::Base
  attr_accessible :base_threshold, :capacity, :charge_rate, :description, :name, :storage, :units, :usage, :user_id, :water_heat_flag

  validates :name, uniqueness: true, presence: true
  validates :capacity, presence: true, numericality: true
  validates :charge_rate, presence: true, numericality: true 
  validates :units, presence: true, numericality: { only_integer: true }
  validates :usage, presence: true, numericality: true
  validates :base_threshold, presence: true, numericality: true
  validates :water_heat_flag, presence: true
  before_save :on_before_save
  belongs_to :user
  has_and_belongs_to_many :calculations


  private

  def on_before_save
   
    self.storage = self.capacity 
  end

end
