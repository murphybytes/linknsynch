class SetMeta < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :samples, :autosave => true, :dependent => :delete_all
  belongs_to :user
  validates :name, :uniqueness => true
  
  def get_first_sample_date
    Sample.minimum( 'sample_time', :conditions => { :set_meta_id => self.id } )
  end
  
  def get_ceiling_sample_date
    dt = Sample.maximum( 'sample_time', :conditions => { :set_meta_id => self.id } ) 
    dt += 1.hour
  end

end
