

class GraphsController < ApplicationController 
  before_filter :authenticate_user!

  def duration

    respond_to do | format |
      format.json { render :json => { response: 'ok' }.to_json }
    end
  end
end
