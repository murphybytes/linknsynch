require 'pqr/series_calculator'

class GraphsController < ApplicationController 
  before_filter :authenticate_user!

  def generation
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    calculator = PQR::SeriesCalculator.new( samples: samples, partition_count: 100 )
    series = calculator.get_generation_series

    logger.debug "SERIES #{series}"

    respond_to do |format|
      format.json { render :json => { 
          month: params[:month], 
          year: params[:year], 
          series: series }.to_json }
    end
  end

  def demand
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    home_profile = HomeProfile.find(params[:home_profile_id])
    calculator = PQR::SeriesCalculator.new( samples: samples, home_profile: home_profile, partition_count: 100 )
    series = calculator.get_demand_series

    logger.debug "SERIES #{series}"

    respond_to do |format|
      format.json { render :json => { 
          month: params[:month], 
          year: params[:year], 
          series: series }.to_json }
    end
  end

  def duration

    respond_to do | format |
      format.json { render :json => { response: 'ok' }.to_json }
    end
  end
end
