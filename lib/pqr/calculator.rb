module PQR

  BTU_TO_KW_CONVERSION_FACTOR=3413.0

  class Calculator
    attr_reader :total_kw_generated, :total_kw_required_for_heating, :total_kw_load_unserved

    def initialize( opts = {}  )
      @total_kw_generated = 0
      @total_kw_required_for_heating = 0
      @total_kw_load_unserved = 0

      @samples = opts.fetch( :samples )
      @home_profile = opts.fetch( :home_profile )
    end

    def run
      total_kw_generated = 0
      # use a float to avoid rounding errors accruing
      total_kw_required_for_heating = 0.0
      total_kw_load_unserved = 0.0

      @samples.each do |sample|

        kw_generated = sample.generated_kilowatts
        total_kw_generated += kw_generated

        kw_required_for_heating = get_kw_required_for_heating( sample )
        total_kw_required_for_heating += kw_required_for_heating

        kw_load_unserved = get_kw_load_unserved( kw_generated, kw_required_for_heating )
        total_kw_load_unserved += kw_load_unserved

      end

      @total_kw_generated = total_kw_generated
      @total_kw_required_for_heating = total_kw_required_for_heating.round 
      @total_kw_load_unserved = total_kw_load_unserved.round
    end

    private
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
