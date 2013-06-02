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

  def summary
    samples = Sample.samples_for_month( params[:set_id], params[:year], params[:month] )
    home_profile = HomeProfile.find( params[:home_profile_id] ) 
    thermal_profiles = ThermalStorageProfile.find( :all, *params[:thermal_storage_ids] )
    thermal_storage_model  = PQR::ThermalStorageModel.new( *thermal_profiles )
    calculator = PQR::Calculator.new( samples: samples, home_profile: home_profile, thermal_storage_model: thermal_storage_model )
    calculator.run

    required_for_heating = calculator.total_kw_required_for_heating - (calculator.total_kw_required_for_heating.to_i & calculator.total_kw_required_for_heating_ls.to_i )
    required_for_heating_ls = calculator.total_kw_required_for_heating_ls - (calculator.total_kw_required_for_heating.to_i & calculator.total_kw_required_for_heating_ls.to_i )
    logger.debug "required for heating #{calculator.total_kw_required_for_heating} with ls #{calculator.total_kw_required_for_heating_ls}"
    logger.debug "required for heating #{required_for_heating} with ls #{required_for_heating_ls}"

    respond_to do | format |
      format.json { render :json => {
          month: params[:month],
          year: params[:year],
          total_kw_required_for_heating: required_for_heating,
          total_kw_required_for_heating_ls: required_for_heating_ls,
          total_kw_load_unserved: calculator.total_kw_load_unserved - (calculator.total_kw_load_unserved.to_i & calculator.total_kw_load_unserved_ls.to_i) ,
          total_kw_load_unserved_ls: calculator.total_kw_load_unserved_ls- (calculator.total_kw_load_unserved.to_i & calculator.total_kw_load_unserved_ls.to_i)
        }.to_json }
    end

  end

  def duration

    respond_to do | format |
      format.json { render :json => { response: 'ok' }.to_json }
    end
  end
end
