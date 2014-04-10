require 'pqr/common'

module PQR
  class ThermalStorageModel

    include PQR::Common

    attr_reader :unit_count
    attr_reader :thermal_storages 
    attr_reader :total_on_peak_sunk
    attr_reader :total_off_peak_sunk
    attr_reader :total_on_peak_sunk_ls
    attr_reader :total_off_peak_sunk_ls
    attr_reader :total_price_on_peak_sunk
    attr_reader :total_price_off_peak_sunk
    attr_reader :total_price_on_peak_sunk_ls
    attr_reader :total_price_off_peak_sunk_ls


    def initialize( thermal_storages, prices, log = nil )
      @log = log
      @prices = prices
      @unit_count = 0
      @total_on_peak_sunk = BigDecimal.new( "0" )
      @total_price_on_peak_sunk = BigDecimal.new( "0" )
      @total_off_peak_sunk = BigDecimal.new( "0" )
      @total_price_off_peak_sunk = BigDecimal.new( "0" )
      @total_on_peak_sunk_ls = BigDecimal.new( "0" )
      @total_off_peak_sunk_ls = BigDecimal.new( "0" )
      @total_price_on_peak_sunk_ls = BigDecimal.new("0")
      @total_price_off_peak_sunk_ls = BigDecimal.new("0")
      @total_off_peak_supplement_ls = BigDecimal.new( "0" )
      @total_price_off_peak_supplement = BigDecimal.new("0")

      @thermal_storages = thermal_storages.each_with_object([]) do |profile, arr|
        @unit_count += profile.units
        arr << {
          profile: profile,
          available_energy: profile.units * profile.storage,
          available_energy_ls: profile.units * profile.storage, 
          capacity: profile.units * profile.capacity,
          base_threshold: profile.units * profile.base_threshold,
          charge_rate: profile.units * profile.charge_rate,
          usage: profile.units * profile.usage,
          water_heat_flag: profile.water_heat_flag == 1,
          energy_used: BigDecimal.new("0"),
          energy_used_ls: BigDecimal.new("0"),
          sunk_on_peak: BigDecimal.new("0"),
          price_sunk_on_peak: BigDecimal.new( "0" ),
          sunk_off_peak: BigDecimal.new( "0" ),
          price_sunk_off_peak: BigDecimal.new( "0" ),
          off_peak_supplement: BigDecimal.new("0"),  # used to cover unserved interruptable needs
          price_off_peak_supplement: BigDecimal.new("0"),
          off_peak_supplement_ls: BigDecimal.new( "0" ),
          price_off_peak_supplement_ls: BigDecimal.new( "0" ),
          sunk_off_peak_ls: BigDecimal.new("0"),
          price_sunk_off_peak_ls: BigDecimal.new( "0" ),
          sunk_on_peak_ls: BigDecimal.new( "0" ),
          price_sunk_on_peak_ls: BigDecimal.new("0"),
          off_peak_load_unserved_ls: BigDecimal.new("0"),
          price_off_peak_load_unserved_ls: BigDecimal.new("0")

        }
      end
    end



    def log_debug( msg )
      if @log
        @log.debug msg
      else
        puts "INFO #{msg}"
      end
    end

    def log_info( msg )
      if @log
        @log.info msg
      else
        puts "INFO #{msg}"
      end
    end

    def get_available
      response = BigDecimal.new( "0" )            
      @thermal_storages.each do | profile |
        response += get_available_for_unit( profile ) 
      end
      response 
    end

    def get_available_ls
      response = BigDecimal.new( "0" )            
      @thermal_storages.each do | profile |
        response += get_available_for_unit_ls( profile ) 
      end
      response 
    end


    ###########################################################
    # Used to indicate that we've used some energy from
    # thermal storage.  If requested_energy exceeds
    # the amount of energy we have available, and exception
    # will be thrown
    #############################################################
    def reduce_available( sample_time, requested_energy )
      available_energy = get_available
      raise "Cannot use more energy than we have. Available #{ available_energy }. Requested #{ requested_energy}" if requested_energy > available_energy
      return if available_energy <= 0

      @thermal_storages.each do | profile |
        available_for_unit = get_available_for_unit( profile )
        unit_portion = available_for_unit / available_energy
        energy_portion = ( unit_portion * requested_energy )
        profile[:available_energy] -= energy_portion
        profile[:off_peak_supplement] += energy_portion
        profile[:price_off_peak_supplement] += get_price( sample_time, @prices, energy_portion ) 
      end

    end

    def reduce_available_ls( sample_time, requested_energy )
      available_energy = get_available_ls
      raise "Cannot use more energy than we have. Available #{ available_energy }. Requested #{ requested_energy}" if requested_energy > available_energy
      return if available_energy <= 0

      @thermal_storages.each do | profile |
        available_for_unit = get_available_for_unit_ls( profile )
        unit_portion = available_for_unit / available_energy
        energy_portion = ( unit_portion * requested_energy )
        profile[:available_energy_ls] -= energy_portion
        profile[:off_peak_supplement_ls] += energy_portion 
        profile[:price_off_peak_supplement_ls] += get_price( sample_time, @prices, energy_portion )
      end

    end

    ##############################################
    #  applies normal energy usage during period
    #  TO DO: add a day / night component to usage
    #  for example, you more water heat during day
    #############################################
    def apply_normal_usage( sample )
      @thermal_storages.each do | profile |

        if profile[:available_energy] > 0
          profile[:available_energy] -= get_usage( profile, sample )
          profile[:available_energy] = 0 if profile[:available_energy] < 0
        end

      end
    end

    def get_usage( profile, sample )
      dbprofile = profile[:profile]
      if dbprofile.water_heat_flag == 1
        profile[:usage]
      else
        get_kw_required_for_heating2( dbprofile.thermostat_temperature, 
                                      dbprofile.base_temperature, 
                                      sample.temperature, 
                                      dbprofile.btu_factor, 
                                      dbprofile.units )
      end
    end

    def apply_normal_usage_ls( sample )
      @thermal_storages.each do | profile |
        if profile[:available_energy_ls] > 0
          profile[:available_energy_ls] -= get_usage( profile, sample )
          profile[:available_energy_ls] = 0 if profile[:available_energy_ls] < 0
        end
      end
    end

    def total_off_peak_load_unserved_ls
      get_total( :off_peak_load_unserved_ls )
    end


    def total_off_peak_supplement
      get_total( :off_peak_supplement )
    end

    def total_off_peak_supplement_ls
      get_total(:off_peak_supplement_ls )
    end 

    def price_total_off_peak_supplement
      get_total(:price_off_peak_supplement)
    end

    def price_total_off_peak_supplement_ls
      get_total( :price_off_peak_supplement_ls )
    end

    def total_capacity 
      total_capacity = 0.0
      @thermal_storages.each do | s |
        total_capacity += s[:capacity]
      end
      total_capacity
    end

    def total_storage
      total_storage = 0.0
      @thermal_storages.each do | s |
        total_storage += s[:available_energy]
      end
      total_storage
    end

    def update( available_energy, sample )
      apply_normal_usage( sample )
      apply_normal_usage_ls( sample )
      remaining_energy     = update_( available_energy, sample )
      remaining_energy_ls  = update_ls_( available_energy, sample )
      [remaining_energy, remaining_energy_ls]
    end

    #############################################################
    # if thermal storage drops below charge threshold, charge
    # it up as much as we can, and reduce the amount of 
    # energy that is available
    #############################################################
    def update_( available_energy, sample )
      remaining_energy = available_energy
      @thermal_storages.each do | ts |
        #if ts[:available_energy] < ts[:capacity]
        if ts[:available_energy] <= ts[:base_threshold]
          amount_to_charge = ts[:capacity] - ts[:available_energy]
          charge = [remaining_energy, ts[:charge_rate], amount_to_charge].min
          remaining_energy -= charge
          ts[:available_energy] += charge
          ts[:energy_used] += charge

          if Utils.is_peak?( sample.sample_time ) 
            ts[:sunk_on_peak] += charge
            price_of_charge = get_price( sample.sample_time, @prices, charge )
            ts[:price_sunk_on_peak] += price_of_charge
            @total_on_peak_sunk += charge
            @total_price_on_peak_sunk += price_of_charge
          else
            ts[:sunk_off_peak] += charge
            price_of_charge = get_price( sample.sample_time, @prices, charge )
            ts[:price_sunk_off_peak] += price_of_charge
            @total_off_peak_sunk += charge
            @total_price_off_peak_sunk += price_of_charge
          end

        end
      end
      remaining_energy      
    end
    ##############################################################
    # For link and sync we charge as much as we can off peak
    # on peak we only charge if we have to 
    ##############################################################
    def update_ls_( available_energy, sample )
      if Utils.is_peak?( sample.sample_time ) 
        update_ls_peak_( available_energy, sample ) 
      else
        update_ls_off_peak_( available_energy, sample ) 
      end
    end

    #
    # on peak ls 
    #
    def update_ls_peak_( available_energy, sample )
      @thermal_storages.each do |ts|
        #if ts[:available_energy_ls] < ts[:base_threshold]
        if ts[:available_energy_ls] < ts[:capacity]
          charge = [available_energy, ts[:charge_rate], ts[:capacity] - ts[:available_energy_ls] ].min
          available_energy -= charge
          ts[:available_energy_ls] += charge
          price_of_charge = get_price( sample.sample_time, @prices, charge )
          ts[:sunk_on_peak_ls] += charge
          ts[:price_sunk_on_peak_ls] += price_of_charge
          @total_on_peak_sunk_ls += charge
          @total_price_on_peak_sunk_ls += price_of_charge 
        end
      end
      available_energy 
    end

    def water_heater?( thermal_storage_unit )
      thermal_storage_unit[:profile].water_heat_flag == 1 
    end

    # TODO: CHARGE UP AS MUCH AS WE CAN WITH OFF PEAK
    def update_ls_off_peak_( available_energy, sample ) 
      @thermal_storages.each do |ts|

        charge = [ts[:capacity] - ts[:available_energy_ls], ts[:charge_rate] ].min

        load_unserved = 0.0
        price_load_unserved = 0.0

        if available_energy < charge 
          load_unserved = charge - available_energy 
          price_load_unserved = get_price( sample.sample_time, @prices, load_unserved )

#          ts[:off_peak_supplement_ls] += load_unserved
 #         ts[:price_off_peak_supplement_ls] += price_supplement
          ts[:off_peak_load_unserved_ls] += load_unserved
          ts[:price_off_peak_load_unserved_ls] += price_load_unserved
          available_energy += load_unserved
        end             

        available_energy -= charge

        ts[:available_energy_ls] += charge
        price_of_charge = get_price( sample.sample_time, @prices, charge ) 
        ts[:sunk_off_peak_ls] += charge
        ts[:price_sunk_off_peak_ls] += price_of_charge
        @total_off_peak_sunk_ls += charge
        @total_price_off_peak_sunk_ls += price_of_charge

      end
      available_energy
    end

    #
    # charges storage as much as possible, returns amount of power used
    #
    def charge( kw )
      total_charge = 0.0

      @thermal_storages.each do | s |
        charge = [kw, s[:charge_rate]].min
        storage_available = s[:capacity] - s[:available_energy]
        storage_available_ls = s[:capacity] - s[:available_energy_ls]
        charge = [charge, storage_available].min
        charge_ls = [charge, storage_available_ls].min
        s[:available_energy] += charge
        s[:available_energy_ls] += charge_ls
        
        #s[:available_energy_ls] = charge_ls
        total_charge += charge
        
        kw -= charge
      end

      total_charge
    end

    private 

    def get_available_for_unit( unit )
      [unit[:available_energy] - unit[:base_threshold], 0 ].max
    end

    def get_available_for_unit_ls( unit )
      [unit[:available_energy_ls] - unit[:base_threshold], 0 ].max
    end


    def get_total( sym )
      result = BigDecimal.new("0")
      @thermal_storages.each do |ts|
        result += ts[sym]
      end
      result
    end


  end
end
