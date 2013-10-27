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
      redirect_to home_profiles_path
    rescue => e
      logger.error e.message
      flash[:alert] = e.message
      render :action => 'new'
    end

  end

  

  def show 
    @profile ||= HomeProfile.find( params[:id] )
  end

  def destroy
    HomeProfile.delete( params[:id] )
    flash[:notice] = 'Home profile deleted'
    redirect_to home_profiles_path
  end

  def edit
    @profile ||= HomeProfile.find( params[:id] )
  end

  def update 
    begin
      @profile ||= HomeProfile.find( params[:home_profile][:id] )
      @profile.update_attributes( params[:home_profile] )
      flash[:notice] = 'Saved home profile changes'
      redirect_to home_profile_path( params[:id] )
    rescue => e
      flash[:alert] = 'Home profile update failed'
      logger.error e.message
      render :action => 'edit'
    end
  end

end
