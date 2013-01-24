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
      @set ||= SetMeta.find( params[:set] )
      @home_profile ||= HomeProfile.find( params[:home_profile] )
      @thermal_profiles ||= ThermalStorageProfile.find( :all, *params[:thermal_storage_profile] )
      @model ||= PQR::ThermalStorageModel.new( *@thermal_profiles ) 
      @calculation = PQR::Calculator.new( samples: @set.samples, home_profile: @home_profile, thermal_storage_model: @model )
      @calculation.run
    rescue => e
      flash[:alert] = 'Calculation failed'
      logger.error e.message
    end
  end

end
