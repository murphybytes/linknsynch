class SetMetasController < ApplicationController
  before_filter :authenticate_user!
  def new
    @set ||= SetMeta.new
  end

  def index
    logger.debug "Called index"
    @sets = SetMeta.where( user_id: current_user.id )
  end

  def edit
    @set ||= SetMeta.find( params[:id] )
  end

  def create
    begin
      original_filename = params[:upload_file][:file].original_filename
      @io = StringIO.new( params[ :upload_file ][:file].read )

      @set = SetMeta.new( params[:set_meta] )
      @set.user = current_user
      @set.save

      logger.debug "New set #{@set.attributes}"

      logger.debug "Started writing file #{original_filename} to db"
      @io.each_line do | line |
        iso_date, temp, kilowatts = line.split( "," )
        @set.samples << Sample.new( :sample_time => DateTime.parse( iso_date.strip ),
                             :temperature => temp.strip,
                             :generated_kilowatts => kilowatts.strip )
      end

      if @set.save
        flash[:notice] = "Uploaded #{@original_filename}"
        redirect_to set_metas_path
      else
        render :action => "new" 
      end
      logger.debug "Finished writing file #{@original_filename} to db"

    rescue => e
      logger.error e.message
    end
  end

  def show 
    @set ||= SetMeta.find( params[:id] )
  end
 
end
