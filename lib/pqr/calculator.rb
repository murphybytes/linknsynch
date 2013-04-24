module PQR

  BTU_TO_KW_CONVERSION_FACTOR=3413.0

  class Calculator
    attr_reader :total_kw_generated, :total_kw_required_for_heating, :total_kw_load_unserved
    attr_reader :total_kw_load_unserved_ls, :total_kw_excess_off_peak_capacity, :total_kw_required_for_heating_ls
    attr_reader :begin_time, :end_time

    def initialize( opts = {}  )
      @total_kw_generated = 0
      @total_kw_required_for_heating = 0
      @total_kw_required_for_heating_ls = 0
     @total_kw_load_unserved = 0
      @total_kw_load_unserved_ls = 0
      @total_kw_excess_off_peak_capacity = 0
      @begin_time = nil
      @end_time = nil

      @samples = opts.fetch( :samples )
      @home_profile = opts.fetch( :home_profile )
      @thermal_storage_model = opts.fetch( :thermal_storage_model )
    end

    ######################################################################################
    # Utility function returns an array of month and year of each month in sample
    # in ascending order
    ######################################################################################
    def get_months
      result = []

      unless @begin_time.nil?
        curr = @begin_time
        while curr.year <= @end_time.year && curr.month <= @end_time.month
          result << curr
          curr = curr.next_month
        end
      end

      result      
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

        update_date_range( sample )

        kw_generated = sample.generated_kilowatts
        total_kw_generated += kw_generated

        kw_required_for_heating = get_kw_required_for_heating( sample )
        total_kw_required_for_heating_ls += kw_required_for_heating
        total_kw_required_for_heating += kw_required_for_heating

        kw_load_unserved = get_kw_load_unserved( kw_generated, kw_required_for_heating )
        total_kw_load_unserved += kw_load_unserved
        total_kw_load_unserved_ls += kw_load_unserved

        if kw_load_unserved > 0.0
          adjustment = get_load_unserved_adjustment( kw_load_unserved )
          total_kw_load_unserved_ls -= adjustment
          total_kw_required_for_heating_ls += adjustment
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
    ####################################################################
    # Calculate the maximum amount of energy that we can use to 
    # draw from thermal storage to reduce load unserved.
    ####################################################################
    def get_load_unserved_adjustment( kw_load_unserved ) 
      available = @thermal_storage_model.get_available
      adjustment = [available,kw_load_unserved].min
      @thermal_storage_model.reduce_available( adjustment )
      adjustment
    end

    ######################################################################
    # Load unserved is the difference between the amount of power 
    # we need and the amount of power we have if we need more than we have
    ########################################################################
    def get_kw_load_unserved( kw_generated, kw_required_for_heating )
      result = 0.0
      # TODO: we should probably use total kw required instead of just
      # kw required for heating, specifically if thermal storage
      # falls below base threshold we have to charge so this
      # power should be included here
      if kw_generated < kw_required_for_heating
        result = kw_required_for_heating - kw_generated
      end
      result
    end

    ####################################################################
    # Calculate the energy required for heating during period
    #
    # Base temperature is set in home profiles.  If the air temperature
    # is at or below this temp, homes in the sample will have their heaters
    # turned on.  The air temperature must be at or below the base temperature
    # in order for energy to be required for heating.  If this is true we calculate
    # the energy required for home heating by applying the formula below, note
    # btu factor would be the amount of energy required to keep an average home
    # in the profile at thermal equilibrium for one hour.  We convert this to
    # kiloWatts.
    ########################################################################
    def get_kw_required_for_heating( sample )
      result = 0.0

      if @home_profile.base_temperature > sample.temperature 
        result = ((@home_profile.thermostat_temperature - sample.temperature ) * @home_profile.btu_factor * 
                  @home_profile.home_count )/BTU_TO_KW_CONVERSION_FACTOR
      end

      result
    end

    def update_date_range( sample ) 
      @begin_time = sample.sample_time if (@begin_time.nil? || @begin_time > sample.sample_time )
      @end_time = sample.sample_time if ( @end_time.nil? || @end_time < sample.sample_time ) 
    end

  end

end
