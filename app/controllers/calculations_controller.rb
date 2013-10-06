require 'pqr/utils'
require 'pqr/thermal_storage_model'
require 'pqr/calculator'
require 'pqr/interruptable_model'
 


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
      @scenario = Calculation.new
      @scenario.name = params[:name]
      @scenario.user = current_user
      @dataset_id = params[:set]

      @set = SetMeta.find( params[:set] )
      @scenario.set_meta = @set

      @prices = LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', @set.get_first_sample_date, @set.get_ceiling_sample_date )
      @scenario.node = Node.name_is( 'OTP.HOOTL2' ).first 
      @thermal_profiles = ThermalStorageProfile.find( params[:thermal_storage_profile] )
      @scenario.thermal_storage_profiles.concat @thermal_profiles
      @thermal_storage_model = PQR::ThermalStorageModel.new( @thermal_profiles, @prices ) 
 
     @home_profiles = HomeProfile.find( params[:home_profile] )
      @scenario.home_profiles.concat @home_profiles
      @scenario.save!
      @interruptable_model = PQR::InterruptableModel.new( @home_profiles, @prices, @thermal_storage_model )
      @calculation = PQR::Calculator.new( @set.samples, @interruptable_model )
      @calculation.run
      @months = @calculation.get_months

    rescue => e
      flash[:alert] = 'Calculation failed'
      logger.error e.message
      logger.error e.backtrace.join( "\n" )
    end
  end

end
