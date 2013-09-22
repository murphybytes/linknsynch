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
    
    home_profiles = HomeProfile.find(:all, *params[:home_profile_ids])
    calculator = PQR::SeriesCalculator.new( samples: samples, home_profiles: home_profiles, partition_count: 100 )
    series = calculator.get_demand_series

    logger.debug "SERIES #{series}"

    respond_to do |format|
      format.json { render :json => { 
          month: params[:month], 
          year: params[:year], 
          series: series }.to_json }
    end
  end


  def create_interruptable_model( year, month, interruptable_profile_ids, thermal_storage_profile_ids )
    logger.debug "y #{year} m #{month} #{interruptable_profile_ids} #{thermal_storage_profile_ids}"
    start_date = DateTime.new( year.to_i, month.to_i ) 
    end_date = start_date.advance( month: 1 ) 
    prices = LocationMarginalPrice.get_prices_for_node_in_range( 'OTP.HOOTL2', start_date, end_date )
    thermal_storage_profiles = ThermalStorageProfile.find( :all, *thermal_storage_profile_ids )
    thermal_storage_model = PQR::ThermalStorageModel.new( thermal_storage_profiles, prices )
    interruptable_storage_profiles = HomeProfile.find( :all, *interruptable_profile_ids ) 
    PQR::InterruptableModel.new( interruptable_storage_profiles, prices, thermal_storage_model )
  end
  
  def unservedsummary
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    interruptable_model = create_interruptable_model( params[:year], params[:month], params[:home_profile_ids], params[:thermal_storage_ids] )
    calculator = PQR::Calculator.new( samples, interruptable_model ) 
    calculator.run

    load_unserved = calculator.total_kw_load_unserved.to_i
    load_unserved_ls = calculator.total_kw_load_unserved_ls.to_i
    min_y = ([load_unserved, load_unserved_ls ].min * 0.99 ).to_i

    respond_to do | format |
      format.json { render :json => {
          month: params[:month],
          year: params[:year],
          load_unserved: load_unserved,
          load_unserved_ls: load_unserved_ls,
          min_y: min_y
        }.to_json }
    end

  end

  def heatingsummary
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    interruptable_model = create_interruptable_model( params[:year], params[:month], params[:home_profile_ids], params[:thermal_storage_ids] )
    calculator = PQR::Calculator.new( samples, interruptable_model ) 
    calculator.run    

    min_y = ([calculator.total_kw_required_for_heating, calculator.total_kw_required_for_heating_ls ].min * 0.99 ).to_i

    respond_to do | format |
      format.json { render :json => {
          month: params[:month],
          year: params[:year],
          total_kw_required_for_heating: calculator.total_kw_required_for_heating,
          total_kw_required_for_heating_ls: calculator.total_kw_required_for_heating_ls,
          min_y: min_y
        }.to_json }
    end

  end

  def duration

    respond_to do | format |
      format.json { render :json => { response: 'ok' }.to_json }
    end
  end
end
