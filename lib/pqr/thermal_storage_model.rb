

module PQR
  class ThermalStorageModel
    attr_reader :unit_count
    def initialize( *thermal_storages )

      @unit_count = 0

      @thermal_storages = thermal_storages.each_with_object([]) do |profile, arr|
        @unit_count += profile.units
        arr << {
          profile: profile,
          available_energy: profile.units * profile.storage,
          capacity: profile.units * profile.capacity,
          base_threshold: profile.units * profile.base_threshold,
          charge_rate: profile.units * profile.charge_rate,
          usage: profile.units * profile.usage,
          energy_used: BigDecimal.new("0"),
          energy_used_ls: BigDecimal.new("0"),
          energy_used_for_heating: BigDecimal.new("0")  # used to cover unserved interruptable needs
        }
      end
    end

    def get_available
      response = BigDecimal.new( "0" )            
      @thermal_storages.each do | profile |
        response += get_available_for_unit( profile ) 
      end
      response 
    end

    ###########################################################
    # Used to indicate that we've used some energy from
    # thermal storage.  If requested_energy exceeds
    # the amount of energy we have available, and exception
    # will be thrown
    #############################################################
    def reduce_available( requested_energy )
      available_energy = get_available
      raise "Cannot use more energy than we have. Available #{ available_energy }. Requested #{ requested_energy}" if requested_energy > available_energy
      return if available_energy <= 0

      @thermal_storages.each do | profile |
        available_for_unit = get_available_for_unit( profile )
        unit_portion = available_for_unit / available_energy
        profile[:available_energy] -= ( unit_portion * requested_energy )
      end

    end
    ##############################################
    #  applies normal energy usage during period
    #  TO DO: add a day / night component to usage
    #  for example, you more water heat during day
    #############################################
    def apply_normal_usage
      @thermal_storages.each do | profile |
        if profile[:available_energy] > 0
          profile[:available_energy] -= profile[:usage]
          profile[:available_energy] = 0 if profile[:available_energy] < 0
        end
      end
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
      remaining_energy, remaining_energy_ls = nil, nil
      
      remaining_energy     = update_( available_energy )
      remaining_energy_ls  = update_ls_( available_energy, sample )

    end

    #############################################################
    # if thermal storage drops below charge threshold, charge
    # it up as much as we can, and reduce the amount of 
    # energy that is available
    #############################################################
    def update_( available_energy )
      remaining_energy = available_energy
      @thermal_storages.each do | ts |
        if ts[:available_energy] < ts[:base_threshold]
          charge = [remaining_energy, ts[:charge_rate]].min
          remaining_energy -= charge
          ts[:available_energy] += charge
        end
      end
      remaining_energy      
    end
    ##############################################################
    # For link and sync we charge as much as we can off peak
    # on peak we only charge if we have to 
    ##############################################################
    def update_ls_( available_energy, sample )
      remaining_energy = available_energy

      if Utils.is_peak?( sample.sample_time )
        remaining_energy = update_( available_energy )
      else
        @thermal_storages.each do | ts |
          possible_charge = [ts[:capacity] - ts[:available_energy], ts[:charge_rate], remaining_energy ].min
          remaining_energy -= possible_charge
          ts[:available_energy] += possible_charge          
        end        
      end

      remaining_energy
    end


    #
    # charges storage as much as possible, returns amount of power used
    #
    def charge( kw )
      total_charge = 0.0

      @thermal_storages.each do | s |
        charge = [kw, s[:charge_rate]].min
        storage_available = s[:capacity] - s[:available_energy] 
        charge = [charge, storage_available].min
        s[:available_energy] += charge
        total_charge += charge
        kw -= charge
      end

      total_charge
    end

    private 

    def get_available_for_unit( unit )
      [unit[:available_energy] - unit[:base_threshold], 0 ].max
    end

  end
end
