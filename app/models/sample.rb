class Sample < ActiveRecord::Base
  attr_accessible :generated_kilowatts, :sample_time, :set_meta_id, :temperature
  has_many :samples, :autosave => true, :dependent => :delete_all
end
