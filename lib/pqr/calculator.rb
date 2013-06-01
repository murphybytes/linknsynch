require 'pqr/common'

module PQR

  class Calculator
    attr_reader :total_kw_generated, :total_kw_required_for_heating, :total_kw_load_unserved
    attr_reader :total_kw_generated_price
    attr_reader :total_kw_load_unserved_ls, :total_kw_excess_off_peak_capacity, :total_kw_required_for_heating_ls
    attr_reader :begin_time, :end_time

    include PQR::Common

    def initialize( opts = {}  )
      @total_kw_generated = 0
      @total_kw_generated_price = 0
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
      @prices = hashify( opts.fetch( :prices, nil ) )
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
      total_kw_generated = 0
      total_kw_generated_price = 0
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
        total_kw_generated_price += get_price( sample, kw_generated )
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
      @total_kw_generated_price = total_kw_generated_price
      @total_kw_required_for_heating = total_kw_required_for_heating.round 
      @total_kw_load_unserved = total_kw_load_unserved.round
      @total_kw_load_unserved_ls = total_kw_load_unserved_ls.round
      @total_kw_excess_off_peak_capacity = total_kw_excess_off_peak_capacity.round
      @total_kw_required_for_heating_ls = total_kw_required_for_heating_ls.round
    end

    private

    def hashify( prices )
      result = nil
      if prices
        result = {}
        prices.each do | p | 
          result[p.period] = p
        end
      end
      result
    end
 
    def get_price( sample, kws )
      result = 0
      if @prices
        hit = @prices[sample.sample_time]
        if hit
          result = kws * ( hit.value / 1000.0 ).to_f
        end
      end
      result
    end

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
