class AdjustTimezone < ActiveRecord::Migration
  include ActiveSupport

  def up
    tz = (TimeZone.new( "Central Time (US & Canada)" ).utc_offset / ( 60 * 60 )).to_s
    Sample.all.each do | s |
      s.sample_time = DateTime.new( s.sample_time.year, s.sample_time.month, s.sample_time.day, s.sample_time.hour, 0, 0, tz ) 
      s.save!
    end
  end

  def down
    tz = (TimeZone.new( "UTC" ).utc_offset / ( 60 * 60 )).to_s 
    Sample.all.each do | s |
      s.sample_time = DateTime.new( s.sample_time.year, s.sample_time.month, s.sample_time.day, s.sample_time.hour, 0, 0, tz ) 
      s.save!
    end
  end
end
