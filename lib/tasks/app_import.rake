namespace :app do
  namespace :import do
    desc "Imports LMP archive files into database"
    task :lmp => :environment do
      require 'csv'
      require 'pqr/utils'
      include ActiveSupport
      puts "calculating tz offset"
      tz_offset = (TimeZone.new( "Eastern Time (US & Canada)" ).utc_offset / ( 60 * 60 )).to_s
      puts "tz offset is #{tz_offset}"
      puts "deleting all LMP data prior to reimporting it"

      Node.delete_all
      LocationMarginalPrice.delete_all

      puts "decompressing import files"

      Dir.glob( 'import/*.zip' ) do |f|
        `unzip -o #{f} -d import`
      end

      

      Dir.glob( 'import/**/*.csv' ) do |f| 
        contents = CSV.read( f )

        month,day,year = PQR::Utils.get_month_day_year( contents[1][0] )
        puts "Processing #{contents[1][0]}"

        ( 5...contents.size ).each do |row|
          node_name = contents[row][0]
          
          if ["OTP.HOOTL2","OTP.HOOTL3"].include?( node_name ) 
            
            node = Node.find_or_create_by_name( contents[row][0] )

            ( 3...contents[row].size).each do |col|
              lmp = LocationMarginalPrice.new
              hour = col - 2
              lmp.period = DateTime.new( year, month, day, hour, 0, 0, tz_offset )
              puts "Processing #{node_name} for #{lmp.period}"
              lmp.value = contents[row][col].to_f
              node.location_marginal_prices << lmp            
            end
            puts "Saving %s for %.2d/%.2d/%.4d" % [node_name,month,day,year]
            node.save

          else
            #puts "Skipping #{node_name}"
          end
          
        end
        
      end
    end
  end
end
