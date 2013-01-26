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

  def destroy
    SetMeta.delete( params[:id] )
    redirect_to set_metas_path
  end

  def show 
    @set ||= SetMeta.find( params[:id] )
  end

  def update
    begin
      @set ||= SetMeta.find( params[:set_meta][:id] )
      @set.update_attributes!( params[:set_meta] )
      flash[:notice] = 'Updated sample information'
      redirect_to set_meta_path
    rescue => e
      flash[:alert] = 'Update failed'
      render :action => :edit
    end 
  end
 
end
