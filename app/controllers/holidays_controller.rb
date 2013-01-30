class HolidaysController < ApplicationController
  before_filter :authenticate_user!

  def index
    @holidays = Holiday.all
  end

  def new
    @holiday = Holiday.new
  end

  def show 
    @holiday = Holiday.find( params[:id] )
  end

  def edit
    @holiday = Holiday.find( params[:id] )
  end

  def update

    begin
      @holiday = Holiday.find( params[:holiday][:id] )
      @holiday.update_attributes( params[:holiday] )
      flash[:notice] = 'Holiday Changes Saved'
      redirect_to holidays_path
    rescue => e
      logger.error e.message
      flash[:alert] = e.message
      render :action => 'edit'
    end
    
  end

  def destroy
    Holiday.delete( params[:id] )
    flash[:notice] = 'Holiday deleted' 
    redirect_to holidays_path
  end

  def create
    begin
      Holiday.create!( params[:holiday] )
      flash[:notice] = 'Created Holiday'
      redirect_to holidays_path
    rescue => e
      logger.error e.message
      flash[:alert] = e.message
      @holiday = Holiday.new( params[:holiday] )
      render :action => 'new'
    end
    
  end

end
