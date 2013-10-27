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

  def index
    @calculations ||= Calculation.where( user_id: current_user.id ) 
  end


  def show
    @scenario ||= Calculation.find( params[:id] )
  end

  

  def destroy 
    logger.debug "called destroy"
    Calculation.delete( params[:id] )
    flash[:notice]  = 'Scenario deleted'
    logger.debug "destroy complete"
    redirect_to calculations_path 
  end

  def update
    logger.debug "PARAMS -> #{ params }"
    
    @scenario ||= Calculation.find( params[:id] )
    params[:calculation][:thermal_storage_profiles]  = ThermalStorageProfile.find( params[:calculation][:thermal_storage_profiles] )
    params[:calculation][:home_profiles]  = HomeProfile.find( params[:calculation][:home_profiles] )
    params[:calculation][:set_meta] = SetMeta.find( params[:calculation][:set_meta] )
    @scenario.update_attributes( params[:calculation] )
    redirect_to calculation_path( params[:id] )
  end


  def edit
    @set_metas = SetMeta.where( user_id: current_user.id )
    @home_profiles = HomeProfile.where( user_id: current_user.id )
    @thermal_profiles = ThermalStorageProfile.where( user_id: current_user.id )

    @scenario ||= Calculation.find( params[:id] )
    
  end

  def create
    logger.debug "CALCULATION CREATE WITH #{params}"

    begin
      if params[:id].present?
        @scenario = Calculation.find( params[:id] )
        @dataset_id = @scenario.set_meta.id
        @prices = LocationMarginalPrice.get_prices_for_node_in_range( @scenario.node.name, 
                                                                    @scenario.set_meta.get_first_sample_date,
                                                                    @scenario.set_meta.get_ceiling_sample_date )
        @thermal_storage_model = PQR::ThermalStorageModel.new( @scenario.thermal_storage_profiles, @prices )
        @interruptable_model = PQR::InterruptableModel.new( @scenario.home_profiles, 
                                                            @prices, 
                                                            @thermal_storage_model )
        @calculation = PQR::Calculator.new( @scenario.set_meta.samples, @interruptable_model )
        @calculation.run
        @months = @calculation.get_months
      else
        @thermal_storage_profile_ids = params[:thermal_storage_profile]
        @home_profile_ids = params[:home_profile]

        @calculation = nil
        @scenario = Calculation.new

        @dataset_id = params[:set]

        @scenario.name = params[:name]
        @scenario.user = current_user
        @set = nil
        @set = SetMeta.find( params[:set] )
        @scenario.set_meta = @set
        @prices = LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', @set.get_first_sample_date, @set.get_ceiling_sample_date )
        @scenario.node = Node.name_is( 'OTP.HOOTL2' ).first 
        @thermal_profiles = ThermalStorageProfile.find( params[:thermal_storage_profile] )
        @scenario.thermal_storage_profiles.concat @thermal_profiles
        @thermal_storage_model = PQR::ThermalStorageModel.new( @thermal_profiles, @prices, logger ) 

        @home_profiles = HomeProfile.find( params[:home_profile] )
        @scenario.home_profiles.concat @home_profiles
        @scenario.save!
        @interruptable_model = PQR::InterruptableModel.new( @home_profiles, @prices, @thermal_storage_model )
        @calculation = PQR::Calculator.new( @set.samples, @interruptable_model )

        @calculation.run
        @months = @calculation.get_months
      end
    rescue => e
      flash[:alert] = 'Calculation failed'
      logger.error e.message
      logger.error e.backtrace.join( "\n" )
    end
  end

end
