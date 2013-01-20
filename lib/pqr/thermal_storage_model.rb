

module PQR
  class ThermalStorageModel
    attr_reader :unit_count
    def initialize( *thermal_storages )
      @thermal_storages = thermal_storages
      @unit_count = 0.0
      @thermal_storages.each { | ts | @unit_count += ts.units }
    end

    def get_available
      response = 0.0
      @thermal_storages.each do | ts |
        response += [( ts.storage - ts.base_threshold ), 0 ].max
      end
      response 
    end

    def reduce_available( adjustment )
      @thermal_storages.each do | ts |
        portion = ( ts.units / @unit_count ) * adjustment
        ts.storage -= portion
      end
    end

    def apply_normal_usage
      @thermal_storages.each do | ts |
        if ts.storage >= ts.usage
          ts.storage -= ts.usage
        end
      end
    end

    def total_capacity 
      total_capacity = 0.0
      @thermal_storages.each do | ts |
        total_capacity += ts.capacity
      end
      total_capacity
    end

    def total_storage
      total_storage = 0.0
      @thermal_storages.each do | ts |
        total_storage += ts.storage
      end
      total_storage
    end
    #
    # charges storage as much as possible, returns amount of power used
    #
    def charge( kw )
      total_charge = 0.0

      @thermal_storages.each do | ts |
        charge = [kw, ts.charge_rate].min
        storage_available = ts.capacity - ts.storage
        charge = [charge, storage_available].min
        ts.storage += charge
        total_charge += charge
      end

      total_charge
    end

  end
end
