module PQR

  BTU_TO_KW_CONVERSION_FACTOR=3413.0
  KW_TO_MW=BigDecimal.new("1000.0")

  module Common
    
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
    def get_kw_required_for_heating( interruptable_profile, sample )
      result = 0.0

      if interruptable_profile.base_temperature > sample.temperature 
        result = ((interruptable_profile.thermostat_temperature - sample.temperature ) * interruptable_profile.btu_factor * 
                  interruptable_profile.home_count )/BTU_TO_KW_CONVERSION_FACTOR
      end

      result
    end


    def get_kw_required_for_heating2( thermostat_temp, base_temp, outdoor_temp, btu_factor, count  )
      result = 0.0

      if base_temp > outdoor_temp
        result = ((thermostat_temp - outdoor_temp ) * btu_factor * count )/BTU_TO_KW_CONVERSION_FACTOR
      end

      result
    end




    def get_price( sample_time, prices, kws )
      price = prices[sample_time]
      if price.nil?
        BigDecimal.new("0")
      else
        kws * ( price.value / KW_TO_MW ).to_f
      end      
    end
    
  end
end
