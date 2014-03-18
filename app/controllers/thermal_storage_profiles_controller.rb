class ThermalStorageProfilesController < ApplicationController
  before_filter :authenticate_user!
  def new
    @profile ||= ThermalStorageProfile.new
    @profile.user_id = current_user.id
  end

  def index
    logger.debug "Called index"
    @profiles = ThermalStorageProfile.where( user_id: current_user.id ) 

  end

  def create
    begin
      logger.debug "CURRENT USER #{current_user.id}"
      @profile = ThermalStorageProfile.create( params[:thermal_storage_profile] )
      flash[:notice] = "Created Thermal Storage Profile"
      redirect_to thermal_storage_profiles_path
    rescue => e
      flash[:alert] = e.message
      logger.error e.message
      render :action => 'new'
    end    
  end

  def show
    @profile = ThermalStorageProfile.find( params[:id] )
  end

  def destroy
    ThermalStorageProfile.delete( params[:id] )
    flash[:notice] = 'Thermal profile deleted'
    redirect_to thermal_storage_profiles_path
  end

  def edit
    @profile ||= ThermalStorageProfile.find( params[:id] )
  end

  def update
    begin
      logger.debug params
      @profile ||= ThermalStorageProfile.find( params[:thermal_storage_profile][:id] )
      @profile.update_attributes( params[:thermal_storage_profile])
      flash[:notice] = 'Thermal storage updated'
      redirect_to thermal_storage_profile_path( params[:id] )          
    rescue => e
      flash[:alert] = e.message
      logger.error "Thermal storage profile update failed - #{ e.message }"
      render :action => 'edit'
    end
  end
  
end
