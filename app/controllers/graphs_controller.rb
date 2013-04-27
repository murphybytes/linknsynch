

class GraphsController < ApplicationController 
  before_filter :authenticate_user!

  def generation
    series = [[0,10],[1,9],[2,7],[3,4],[4,2]]

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
