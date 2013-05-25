namespace :app do
  namespace :import do
    desc "Imports LMP archive files into database"
    task :lmp => :environment do
      require 'csv'
      require 'pqr/utils'
      include ActiveSupport
      puts "calculating tz offset"
      tz_offset = TimeZone.new( "Eastern Time (US & Canada)" ).utc_offset / ( 60 * 60 )
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
          puts "Processing node #{contents[row][0]}"

          node = Node.find_or_create_by_name( contents[row][0] )

          ( 3...contents[row].size).each do |col|
            lmp = LocationMarginalPrice.new
            hour = col - 2
            lmp.period = DateTime.new( year, month, day, hour, 0, 0, tz_offset )
            lmp.value = contents[row][col].to_f
            node.location_marginal_prices << lmp            
          end

          node.save
          
        end
        
      end
    end
  end
end
