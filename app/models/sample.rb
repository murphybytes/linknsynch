class Sample < ActiveRecord::Base
  attr_accessible :generated_kilowatts, :sample_time, :set_meta_id, :temperature

  belongs_to :set_meta


  def self.samples_for_month( set_meta_id, year, month )
    Rails.env == 'production' ? Sample.samples_for_month_mysql( set_meta_id, year, month ) : Sample.samples_for_month_sqlite( set_meta_id, year, month )
  end

  private

  def self.samples_for_month_sqlite( set_meta_id, year, month )
    Sample.where("set_meta_id = ?  AND strftime('%Y',sample_time) =  ? AND strftime('%m',sample_time) = ?", set_meta_id, year, '%02d' % month ).order( 'sample_time asc' )
  end

  def self.samples_for_month_mysql( set_meta_id, year, month )
    Sample.where("set_meta_id = ? AND YEAR(sample_time) = ? AND MONTH(sample_time) = ?" , set_meta_id, year, month ).order( 'sample_time asc' )
  end

  


end
