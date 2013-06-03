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

  
  def unservedsummary
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    home_profile = HomeProfile.find( params[:home_profile_id] ) 
    thermal_profiles = ThermalStorageProfile.find( :all, *params[:thermal_storage_ids] )
    thermal_storage_model  = PQR::ThermalStorageModel.new( *thermal_profiles )
    calculator = PQR::Calculator.new( samples: samples, home_profile: home_profile, thermal_storage_model: thermal_storage_model )
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
    home_profile = HomeProfile.find( params[:home_profile_id] ) 
    thermal_profiles = ThermalStorageProfile.find( :all, *params[:thermal_storage_ids] )
    thermal_storage_model  = PQR::ThermalStorageModel.new( *thermal_profiles )
    calculator = PQR::Calculator.new( samples: samples, home_profile: home_profile, thermal_storage_model: thermal_storage_model )
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
