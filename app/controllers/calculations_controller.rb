require 'pqr/utils'
require 'pqr/thermal_storage_model'
require 'pqr/calculator'
 


class CalculationsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @set_metas = SetMeta.where( user_id: current_user.id )
    @home_profiles = HomeProfile.where( user_id: current_user.id )
    @thermal_profiles = ThermalStorageProfile.where( user_id: current_user.id )
  end

  def create
    logger.debug "CALCULATION CREATE WITH #{params}"
    begin
      @dataset_id = params[:set]

      @set = SetMeta.find( params[:set] )
      @prices = LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', @set.get_first_sample_date, @set.get_ceiling_sample_date )
      @thermal_profiles = ThermalStorageProfile.find( :all, *params[:thermal_storage_profile] )
      @thermal_storage_model = PQR::ThermalStorageModel.new( @thermal_profiles, @prices ) 
      @home_profiles = HomeProfile.find( :all, *params[:home_profile] )
      @interruptable_model = PQR::InterruptableModel.new( @home_profiles, @prices, @thermal_storage_model )
      @calculation = PQR::Calculator.new( samples: @set.samples, 
                                          interruptable_model: @interruptable_model, 
                                          thermal_storage_model: @thermal_storage_model)
      @calculation.run
      @months = @calculation.get_months

    rescue => e
      flash[:alert] = 'Calculation failed'
      logger.error e.message
    end
  end

end
