class Sample < ActiveRecord::Base
  attr_accessible :generated_kilowatts, :sample_time, :set_meta_id, :temperature

  belongs_to :set_meta

  

end
