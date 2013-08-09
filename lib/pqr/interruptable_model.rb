############################################################################
#  This model handles multiple interruptable  sources, usually this will
#  be dual fuel heating
###########################################################################
module PQR
  class InterruptableModel
    def initialize( interruptables )
      @interruptables = interruptables.each_with_object([]) do | interruptable_profile, arr |
        arr << {
          profile: interruptable_profile,
          energy_use: BigDecimal.new( "0" ),
          energy_use_with_link_sync: BigDecimal.new( 0 )
        }
      end

      def update_interruptables( available_energy, sample )
        remaining_energy = available_energy

        remaining_energy
      end

    end
  end

end
