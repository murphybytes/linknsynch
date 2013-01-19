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
      flash[:notice] = "Created Profile"
      render :action => 'index'
     rescue => e
       logger.error e.message
      render :action => 'new'
    end
  end

 
end
