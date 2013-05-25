
module PQR

  BTU_TO_KWHOUR=(0.98 * 3412)
  LB_PER_GALLON=8.33

  class Utils
    
    def self.get_month_day_year( val )
      val.strip!
      val.split( '/' ).map do |s|
        s.to_i
      end
    end

    def self.holiday?( yy, mm, dd )
      ts = Date.new( yy, mm, dd )
      Holiday.where( occurance: ts ).exists?
    end

    def self.is_peak?( ts )
      return false if Utils.holiday?( ts.year, ts.month, ts.day )
      # saturday and sunday are off peak
      return false if (ts.wday == 6 || ts.wday == 0)
      return true if (ts.hour >= 7 && ts.hour < 23)
      return false
    end
    
    # calculates kw required to replace hot water
    # args:
    # deltat = delta between temp at tap and desired hot water temp in F
    # gph = gallon used per hour
    def self.gph_to_kwh( gph, deltat =  60 )
      (gph * deltat * LB_PER_GALLON / BTU_TO_KWHOUR)
    end

    def self.f_to_c( tempf ) 
      (tempf - 32) * 5 / 9
    end

    def self.gal_to_liter( gal )
      gal * 3.785411
    end

    def self.calc_energy_stored( gals, basetemp, watertemp )
      # convert temp to C
      basetemp = f_to_c( basetemp )
      watertemp = f_to_c( watertemp )
      liters = gal_to_liter( gals )
      kj = 4.2 * ( watertemp - basetemp ) * liters 
      (kj * 0.000278)
    end

  end
end
