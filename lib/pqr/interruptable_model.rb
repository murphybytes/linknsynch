############################################################################
#  This model handles multiple interruptable  sources, usually this will
#  be dual fuel heating
###########################################################################
require 'pqr/common'

module PQR
  class InterruptableModel
    
    include PQR::Common

    attr_reader :interruptables, :total_energy_used, :price_total_energy_used, :total_energy_needed
    attr_reader :price_total_energy_needed
    attr_reader :total_energy_used_ls, :price_total_load_unserved, :total_load_unserved, :total_load_unserved_ls
    attr_reader :total_load_unserved_ls_price
    attr_reader :thermal_storage_model
    attr_reader :prices

    def initialize( interruptables, prices, thermal_storage_model )
      @prices = prices
      @thermal_storage_model = thermal_storage_model

      @interruptables = interruptables.each_with_object([]) do | interruptable_profile, arr |
        arr << {
          profile: interruptable_profile,
          energy_used: BigDecimal.new( "0" ),
          energy_used_with_ls: BigDecimal.new( "0" ),
          energy_needed: BigDecimal.new("0"),
          energy_needed_lmp: BigDecimal.new("0"),
          load_unserved: BigDecimal.new("0"),
          load_unserved_ls: BigDecimal.new("0"),
          price_load_unserved: BigDecimal.new("0"),
          price_load_unserved_ls: BigDecimal.new( "0" )
          
          
        }
      end

      @total_energy_used              = BigDecimal.new("0")
      @total_energy_used_ls           = BigDecimal.new("0")
      @total_energy_needed            = BigDecimal.new("0")
      @price_total_energy_needed      = BigDecimal.new("0")
      @total_load_unserved            = BigDecimal.new("0")
      @price_total_load_unserved      = BigDecimal.new("0")
      @total_load_unserved_ls         = BigDecimal.new("0")
      @price_total_energy_used        = BigDecimal.new("0")
      @total_load_unserved_ls_price   = BigDecimal.new("0")
    end

    def update( available_energy, available_energy_ls, sample )

      @interruptables.each do | interruptable |
        required_for_heating           = get_kw_required_for_heating( interruptable[:profile], sample )

        interruptable[:energy_needed]     += required_for_heating
        interruptable[:energy_needed_lmp] += get_price( sample, @prices, required_for_heating )
        @total_energy_needed              += required_for_heating

        @price_total_energy_needed    += get_price( sample, @prices, required_for_heating )

        result = calculate_energy_used( available_energy, required_for_heating )

        @total_energy_used            += result[:energy_used]
        @price_total_energy_used      += get_price( sample, @prices, result[:energy_used] )

        @total_load_unserved          += result[:load_unserved]
        price_load_unserved           =  get_price( sample, @prices, result[:load_unserved] )
        @price_total_load_unserved    += price_load_unserved
        interruptable[:price_load_unserved] += price_load_unserved
        interruptable[:energy_used]   += result[:energy_used]
        
        interruptable[:load_unserved] += result [:load_unserved]
        available_energy              = result[:energy_remaining]

        result_ls = calculate_energy_used_ls( available_energy_ls, required_for_heating )

        @total_energy_used_ls               += result_ls[:energy_used]
        @total_load_unserved_ls             += result_ls[:load_unserved]
        price_load_unserved_ls              = get_price( sample, @prices, result_ls[:load_unserved] )
        @total_load_unserved_ls_price       += price_load_unserved_ls
        interruptable[:price_load_unserved_ls] += price_load_unserved_ls

        interruptable[:energy_used_with_ls] += result_ls[:energy_used]
        interruptable[:load_unserved_ls]    += result_ls[:load_unserved]

        available_energy_ls                 = result_ls[:energy_remaining]
      end

      [ available_energy,  available_energy_ls ]
    end

    private

    def calculate_energy_used( energy_available, energy_needed )
      energy_used, load_unserved, energy_remaininig = nil, nil, nil

      if energy_available >= energy_needed 
        energy_used = energy_needed
        load_unserved = BigDecimal.new( "0" )
        energy_remaining = energy_available - energy_used
      else
        energy_used = energy_available
        energy_remaining = BigDecimal.new( "0" )
        load_unserved = energy_needed - energy_available
      end

      {energy_used: energy_used, load_unserved: load_unserved, energy_remaining: energy_remaining}
    end

    def calculate_energy_used_ls( energy_available, energy_needed )
      energy_used, load_unserved, energy_remaininig = nil, nil, nil

      if energy_available >= energy_needed 
        energy_used = energy_needed
        load_unserved = BigDecimal.new( "0" )
        energy_remaining = energy_available - energy_used
      else
        thermal_storage_available = @thermal_storage_model.get_available_ls
        thermal_storage_reduction = [ thermal_storage_available, energy_needed - energy_available ].min
        @thermal_storage_model.reduce_available_ls( thermal_storage_reduction ) 
        energy_used = energy_available + thermal_storage_reduction
        energy_remaining = BigDecimal.new( "0" )
        load_unserved = energy_needed - energy_used

      end

      {energy_used: energy_used, load_unserved: load_unserved, energy_remaining: energy_remaining}
    end
    

  end
end

