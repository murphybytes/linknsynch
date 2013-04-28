require 'pqr/series_calculator'

class GraphsController < ApplicationController 
  before_filter :authenticate_user!

  def generation
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    calculator = PQR::SeriesCalculator.new( samples: samples )
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
  end

  def duration

    respond_to do | format |
      format.json { render :json => { response: 'ok' }.to_json }
    end
  end
end
