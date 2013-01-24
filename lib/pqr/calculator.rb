module PQR

  BTU_TO_KW_CONVERSION_FACTOR=3413.0

  class Calculator
    attr_reader :total_kw_generated, :total_kw_required_for_heating, :total_kw_load_unserved
    attr_reader :total_kw_load_unserved_ls, :total_kw_excess_off_peak_capacity, :total_kw_required_for_heating_ls

    def initialize( opts = {}  )
      @total_kw_generated = 0
      @total_kw_required_for_heating = 0
      @total_kw_required_for_heating_ls = 0
     @total_kw_load_unserved = 0
      @total_kw_load_unserved_ls = 0
      @total_kw_excess_off_peak_capacity = 0

      @samples = opts.fetch( :samples )
      @home_profile = opts.fetch( :home_profile )
      @thermal_storage_model = opts.fetch( :thermal_storage_model )
    end

    def run
      total_kw_generated = 0
      # use a float to avoid rounding errors accruing
      total_kw_required_for_heating = 0.0
      total_kw_required_for_heating_ls = 0.0
      total_kw_load_unserved = 0.0
      total_kw_load_unserved_ls = 0.0
      total_kw_excess_off_peak_capacity = 0.0


      @samples.each do |sample|

        kw_generated = sample.generated_kilowatts
        total_kw_generated += kw_generated

        kw_required_for_heating = get_kw_required_for_heating( sample )
        kw_required_for_heating_ls = kw_required_for_heating
        total_kw_required_for_heating += kw_required_for_heating

        kw_load_unserved = get_kw_load_unserved( kw_generated, kw_required_for_heating )
        total_kw_load_unserved += kw_load_unserved

        if kw_load_unserved > 0.0
          adjustment = get_load_unserved_adjustment( kw_load_unserved )
          total_kw_load_unserved_ls += (kw_load_unserved - adjustment)
          kw_required_for_heating_ls -= adjustment
          total_kw_required_for_heating_ls += kw_required_for_heating_ls
        else
          # if off peak charge thermal storage
          unless Utils.is_peak?( sample.sample_time )
            excess_capacity = [ kw_generated - kw_required_for_heating, 0.0 ].max
            if excess_capacity > 0.0
              used = @thermal_storage_model.charge( excess_capacity )
              total_kw_excess_off_peak_capacity += ( excess_capacity - used )
            end
          end
        end

      end

      @total_kw_generated = total_kw_generated
      @total_kw_required_for_heating = total_kw_required_for_heating.round 
      @total_kw_load_unserved = total_kw_load_unserved.round
      @total_kw_load_unserved_ls = total_kw_load_unserved_ls.round
      @total_kw_excess_off_peak_capacity = total_kw_excess_off_peak_capacity.round
      @total_kw_required_for_heating_ls = total_kw_required_for_heating_ls.round
    end

    private

    def get_load_unserved_adjustment( kw_load_unserved ) 
      available = @thermal_storage_model.get_available
      adjustment = [available,kw_load_unserved].min
      @thermal_storage_model.reduce_available( adjustment )
      adjustment
    end

    def get_kw_load_unserved( kw_generated, kw_required_for_heating )
      result = 0.0
      if kw_generated < kw_required_for_heating
        result = kw_required_for_heating - kw_generated
      end
      result
    end

    def get_kw_required_for_heating( sample )
      result = 0.0

      if @home_profile.base_temperature > sample.temperature 
        result = ((@home_profile.thermostat_temperature - sample.temperature ) * @home_profile.btu_factor * 
                  @home_profile.home_count )/BTU_TO_KW_CONVERSION_FACTOR
      end

      result
    end

  end

end
