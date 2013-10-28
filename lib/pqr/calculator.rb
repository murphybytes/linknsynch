require 'pqr/common'

module PQR

  class Calculator
    attr_reader :total_kw_generated, :total_kw_generated_price
    attr_reader :total_kw_required_for_heating, :total_kw_required_for_heating_price 
    attr_reader :total_kw_load_unserved, :total_kw_load_unserved_price
    attr_reader :total_kw_load_unserved_ls, :total_kw_required_for_heating_ls
    attr_reader :total_kw_load_unserved_ls_price, :total_kw_required_for_heating_ls_price
    attr_reader :begin_time, :end_time
    attr_reader :total_kw_excess_capacity, :total_kw_excess_capacity_price
    attr_reader :total_kw_off_peak_sunk, :total_kw_off_peak_sunk_price
    attr_reader :total_kw_surplus_energy_op_price
    attr_reader :interruptable_model
    attr_reader :total_kw_surplus_energy, :total_kw_surplus_energy_ls
    attr_reader :total_surplus_price, :total_surplus_price_ls

    include PQR::Common

    KW_TO_MW = BigDecimal.new('1000.0')

    def initialize( samples, interruptable_model  )
      @total_kw_generated                = BigDecimal.new( '0' )
      @total_kw_generated_price          = BigDecimal.new( '0' )
      @total_kw_surplus_energy_op        = BigDecimal.new( '0' )
      @total_kw_surplus_energy_op_price  = BigDecimal.new( '0' )
      @total_kw_surplus_energy_op_ls     = BigDecimal.new( '0' )
      @total_kw_surplus_energy           = BigDecimal.new( '0' )
      @total_kw_surplus_energy_ls        = BigDecimal.new( '0' )
      @total_kw_load_unserved            = BigDecimal.new( '0' )
      @total_surplus_price               = BigDecimal.new( '0' )
      @total_surplus_price_ls            = BigDecimal.new( '0' )
   
      @samples = samples
      @interruptable_model = interruptable_model
    end

    def thermal_storage_model
      @interruptable_model.thermal_storage_model
    end

    def interruptable_profiles
      @interruptable_model.interruptables
    end

    def thermal_storage_profiles
      @interruptable_model.thermal_storage_model.thermal_storages
    end

    def total_mw_surplus_energy_off_peak
      (@total_kw_surplus_energy_op / KW_TO_MW).round
    end

    def total_mw_surplus_energy_off_peak_ls
      (@total_kw_surplus_energy_op_ls / KW_TO_MW).round
    end

    def total_mw_excess_capacity
      (@total_kw_excess_capacity / KW_TO_MW).round
    end

    def total_mw_off_peak_sunk
      (@total_kw_off_peak_sunk / KW_TO_MW).round 
    end

    def total_mw_generated
      (@total_kw_generated / KW_TO_MW).round
    end

    def total_mw_required_for_heating
      (@total_kw_required_for_heating / KW_TO_MW).round
    end

    def total_mw_required_for_heating_ls
      (@total_kw_required_for_heating_ls / KW_TO_MW).round
    end

    def total_mw_load_unserved
      (@total_kw_load_unserved / KW_TO_MW).round
    end

    def total_mw_load_unserved_ls
      (@total_kw_load_unserved_ls / KW_TO_MW).round
    end

    def total_mw_surplus_off_peak
      (@total_kw_surplus_energy_off_peak / KW_TO_MW).round
    end

    def total_mw_sunk
      #(@interruptable_model.total_energy_used/KW_TO_MW).round
      ((@total_kw_generated - @total_kw_surplus_energy)/ KW_TO_MW).round
    end

    def total_mw_sunk_ls
      #(@interruptable_model.total_energy_used_ls / KW_TO_MW).round
     ((@total_kw_generated - @total_kw_surplus_energy_ls)/KW_TO_MW).round 
    end

    def pct_sunk
      "#{((1.0 - (@total_kw_surplus_energy / @total_kw_generated)) * 100.0).round( 1 )}%"
    end

    def pct_sunk_ls
      "#{((1.0 - (@total_kw_surplus_energy_ls / @total_kw_generated)) * 100.0).round( 1 )}%"
    end

    def date_in_range?( test )
      return true if test.year < @end_time.year

      if test.year == @end_time.year
        return true if test.month <= @end_time.month
      end

      return false
    end

    ######################################################################################
    # Utility function returns an array of month and year of each month in sample
    # in ascending order
    ######################################################################################
    def get_months
      result = []

      unless @begin_time.nil?
        curr = @begin_time
        while date_in_range?( curr ) 
          result << curr
          curr = curr.next_month
        end
      end

      result      
    end



    def run

      @samples.each do |sample|

        update_date_range( sample )

        kw_generated = sample.generated_kilowatts
        @total_kw_generated +=  kw_generated
        @total_kw_generated_price += get_price( sample.sample_time, @interruptable_model.prices, kw_generated )
   
        kw_available, kw_available_ls = @interruptable_model.thermal_storage_model.update( kw_generated, sample )
        kw_available, kw_available_ls = @interruptable_model.update( kw_available, kw_available_ls, sample )  

        @total_kw_surplus_energy += kw_available if kw_available > 0
        @total_surplus_price += get_price( sample.sample_time, @interruptable_model.prices, kw_available ) if kw_available > 0
        @total_kw_surplus_energy_ls += kw_available_ls if kw_available_ls > 0
        @total_surplus_price_ls += get_price( sample.sample_time, @interruptable_model.prices, kw_available_ls ) if kw_available_ls > 0
      end
           
      @total_kw_required_for_heating = @interruptable_model.total_energy_needed
      @total_kw_required_for_heating_price = @interruptable_model.price_total_energy_needed
      @total_kw_load_unserved = @interruptable_model.total_load_unserved
      @total_kw_load_unserved_price = @interruptable_model.price_total_load_unserved
      
      @total_kw_load_unserved_ls = @interruptable_model.total_load_unserved_ls
      @total_kw_load_unserved_price_ls = @interruptable_model.total_load_unserved_ls_price



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
      # TODO: we should probably use total kw required instead of just
      # kw required for heating, specifically if thermal storage
      # falls below base threshold we have to charge so this
      # power should be included here
      [ kw_required_for_heating - kw_generated, 0.0 ].max
    end


    def update_date_range( sample )
      unless sample.sample_time.nil?
        if @begin_time.nil? 
          @begin_time = sample.sample_time
        end
        
        if @end_time.nil?
          @end_time = sample.sample_time
        end

        @begin_time = sample.sample_time if @begin_time > sample.sample_time 
        @end_time = sample.sample_time if @end_time < sample.sample_time 
      end

    end

  end

end
