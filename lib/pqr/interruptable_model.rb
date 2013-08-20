############################################################################
#  This model handles multiple interruptable  sources, usually this will
#  be dual fuel heating
###########################################################################
require 'pqr/common'

module PQR
  class InterruptableModel
    
    include PQR::Common

    attr_reader :interruptables, :total_energy_used, :total_energy_needed
    attr_reader :total_energy_used_ls, :total_load_unserved, :total_load_unserved_ls
    
    def initialize( interruptables )
      @interruptables = interruptables.each_with_object([]) do | interruptable_profile, arr |
        arr << {
          profile: interruptable_profile,
          energy_used: BigDecimal.new( "0" ),
          energy_used_with_ls: BigDecimal.new( "0" ),
          energy_needed: BigDecimal.new("0"),
          load_unserved: BigDecimal.new("0"),
          load_unserved_with_link_sync: BigDecimal.new("0")
          
        }
      end

      @total_energy_used              = BigDecimal.new("0")
      @total_energy_used_ls           = BigDecimal.new("0")
      @total_energy_needed            = BigDecimal.new("0")
      @total_load_unserved            = BigDecimal.new("0")
      @total_load_unserved_ls         = BigDecimal.new("0")
    end

    def update_interruptables( available_energy, available_energy_ls, sample )

      @interruptables.each do | interruptable |
        interruptable[:energy_needed] = get_kw_required_for_heating( interruptable[:profile], sample )
        @total_energy_needed          += interruptable[:energy_needed]

        result = calculate_energy_used( available_energy, interruptable[:energy_needed] )

        @total_energy_used            += result[:energy_used]
        @total_load_unserved          += result[:load_unserved]

        interruptable[:energy_used]   = result[:energy_used]
        interruptable[:load_unserved] = result [:load_unserved]
        available_energy              = result[:energy_remaining]

        result_ls = calculate_energy_used( available_energy_ls, interruptable[:energy_needed] )

        @total_energy_used_ls               += result_ls[:energy_used]
        @total_load_unserved_ls             += result_ls[:load_unserved]

        interruptable[:energy_used_with_ls] = result_ls[:energy_used]
        interruptable[:load_unserved_ls]    = result_ls[:load_unserved]

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
    

  end
end

