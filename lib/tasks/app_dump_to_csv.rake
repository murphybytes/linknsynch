namespace :app do
  desc "Dumps sample data to spreadsheet where it can be imported into a spreadsheet"
  task :dump_to_csv do
    require 'csv'
    require File.expand_path('../../../config/environment', __FILE__)

    OUTFILE_NAME         ='OUTFILE_NAME'
    SET_NAME             ='SET_NAME'
    THERMAL_STORAGE_NAME ='THERMAL_STORAGE_NAME'
    HOME_PROFILE_NAME    ='HOME_PROFILE_NAME'

    def usage
      puts 'One or more environment variables that this task requires is missing.'
      puts "  #{OUTFILE_NAME}         - path of file containing csv output."
      puts "  #{SET_NAME}             - the name of the set to output."
      puts "  #{THERMAL_STORAGE_NAME} - the name of the thermal storage record to use."
      puts "  #{HOME_PROFILE_NAME}    - the name of the home profile to use."
    end

    begin
      outfile         = ENV.fetch( OUTFILE_NAME )
      home_profile    = HomeProfile.find( :first, :conditions => { :name => ENV.fetch( HOME_PROFILE_NAME ) } )
      thermal_storage = ThermalStorageProfile.find( :first, :conditions => { :name => ENV.fetch( THERMAL_STORAGE_NAME ) } )
      set_meta        = SetMeta.find( :first, :conditions => {  :name => ENV.fetch( SET_NAME ) } )

      CSV.open( outfile, 'wb' ) do | csv |
        csv << [
                'sample time', 
                'generated kw', 
                'outside temperature',
                'home count',
                'btu factor',
                'base temperature',
                'thermostat temperature'

               ]
        set_meta.samples.each do | s |
          putc '.'
          csv << [ 
                  s.sample_time, 
                   s.generated_kilowatts, 
                   s.temperature,
                  home_profile.home_count,
                  home_profile.btu_factor,
                  home_profile.base_temperature,
                  home_profile.thermostat_temperature
                 ]
        end
      end
      
    rescue KeyError => e
      usage
    rescue => e
      puts e.message
    end


    # require 'csv'
    # require 'pqr/utils'
    # include ActiveSupport
    # puts "calculating tz offset"
    # tz_offset = (TimeZone.new( "Eastern Time (US & Canada)" ).utc_offset / ( 60 * 60 )).to_s
    # puts "tz offset is #{tz_offset}"
    # puts "deleting all LMP data prior to reimporting it"

    # Node.delete_all
    # LocationMarginalPrice.delete_all

    # puts "decompressing import files"

    # Dir.glob( 'import/*.zip' ) do |f|
    #   `unzip -o #{f} -d import`
    # end

    

    # Dir.glob( 'import/**/*.csv' ) do |f| 
    #   contents = CSV.read( f )

    #   month,day,year = PQR::Utils.get_month_day_year( contents[1][0] )
    #   puts "Processing #{contents[1][0]}"
    #   ####################################################
    #   # change year so it matches our generation sample
    #   ####################################################
    #   year += 2  


    #   ( 5...contents.size ).each do |row|
    #     node_name = contents[row][0]
    #     node_type = contents[row][2]

    #     if ["OTP.HOOTL2","OTP.HOOTL3"].include?( node_name ) 
    #       if "LMP" == node_type 
    #         node = Node.find_or_create_by_name( contents[row][0] )

    #         ( 3...contents[row].size).each do |col|
    #           lmp = LocationMarginalPrice.new
    #           hour = col - 2
    #           lmp.period = DateTime.new( year, month, day, hour, 0, 0, tz_offset )
    #           puts "Processing #{node_name} for #{lmp.period}"
    #           lmp.value = contents[row][col].to_f
    #           node.location_marginal_prices << lmp
    #         end 
            
    #         puts "Saving %s for %.2d/%.2d/%.4d" % [node_name,month,day,year]
    #         node.save

    #       end


    #     end
        
    #   end
      
    # end


  end

end
