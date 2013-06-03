

module PQR
  class ThermalStorageModel
    attr_reader :unit_count
    def initialize( *thermal_storages )
      @thermal_storages = thermal_storages
      @unit_count = 0.0
      @agg_storage = []
      @thermal_storages.each do | ts | 
        @unit_count += ts.units
        @agg_storage << {
          units: ts.units,
          storage: ts.units * ts.storage,
          capacity: ts.units * ts.capacity,
          base_threshold: ts.units * ts.base_threshold,
          charge_rate: ts.charge_rate * ts.units,
          usage: ts.usage * ts.units
        }
      end
    end

    def get_available
      response = 0.0      
      @agg_storage.each do | s |
        response += [s[:storage] - s[:base_threshold], 0 ].max
      end
      response 
    end

    def reduce_available( adjustment )
      @agg_storage.each do | s |
        portion = ( s[:units] / @unit_count ) * adjustment
        s[:storage] -= portion
      end
    end

    def apply_normal_usage
      @agg_storage.each do | s |
        if s[:storage] > 0
          s[:storage] -= s[:usage]
          s[:storage] = 0 if s[:storage] < 0
        end
      end
    end

    def total_capacity 
      total_capacity = 0.0
      @agg_storage.each do | s |
        total_capacity += s[:capacity]
      end
      total_capacity
    end

    def total_storage
      total_storage = 0.0
      @agg_storage.each do | s |
        total_storage += s[:storage]
      end
      total_storage
    end
    #
    # charges storage as much as possible, returns amount of power used
    #
    def charge( kw )
      total_charge = 0.0

      @agg_storage.each do | s |
        charge = [kw, s[:charge_rate]].min
        storage_available = s[:capacity] - s[:storage] 
        charge = [charge, storage_available].min
        s[:storage] += charge
        total_charge += charge
      end

      total_charge
    end

  end
end
