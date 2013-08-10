############################################################################
#  This model handles multiple interruptable  sources, usually this will
#  be dual fuel heating
###########################################################################
require 'pqr/common'

module PQR
  class InterruptableModel
    include PQR::Common

    def initialize( interruptables )
      @interruptables = interruptables.each_with_object([]) do | interruptable_profile, arr |
        arr << {
          profile: interruptable_profile,
          energy_use: BigDecimal.new( "0" ),
          energy_use_with_link_sync: BigDecimal.new( "0" ),
          energy_needed: BigDecimal.new("0"),
          load_unserved: BigDecimal.new("0"),
          load_unserved_with_link_sync: BigDecimal.new("0")
          
        }
      end
    end

    def update_interruptables( available_energy, available_energy_ls, sample )
      remaining_energy, remaining_energy_ls = available_energy, available_energy_ls

      @interruptables.each do | interruptable |
        interruptable[:energy_needed] = get_kw_required_for_heating( interruptable[:profile], sample ) 
      end

      [remaining_energy, remaining_energy_ls]
    end

    def total_energy_needed
      result = BigDecimal.new( "0" )
      @interruptables.each do | i |
        result += i[:energy_needed]
      end
      result
    end

  end
end

