class HomeProfilesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @profile ||= HomeProfile.new
    @profile.btu_factor = 713.4889
    @profile.thermostat_temperature = 70
    @profile.base_temperature = 60
    @profile.user_id = current_user.id
  end

  def index
    @profiles = HomeProfile.where( user_id: current_user.id )
  end

  def create
    begin
      @profile = HomeProfile.create( params[:home_profile] )
      flash[:notice] = 'Created Home Profile'
      render :action => 'index'
    rescue => e
      logger.error e.message
      flash[:alert] = e.message
      render :action => 'new'
    end
  end


end
