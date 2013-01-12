class SetMetasController < ApplicationController
  before_filter :authenticate_user!
  def new
    @set ||= SetMeta.new
  end

  def index
    logger.debug "Called index"
    @sets = SetMeta.all

  end

  def create
    begin
      logger.debug "CURRENT USER #{current_user.id}"
      original_filename = params[:set_meta][:upload_file].original_filename 
      @io = StringIO.new( params[:set_meta][ :upload_file ].read )
     
      @set = SetMeta.new( name: params[:set_meta][:name], 
                             description:  params[:set_meta][:description] )
      @set.user = current_user
      @set.save

      logger.debug "New set #{@set.attributes}"

      logger.debug "Started writing file #{@original_filename} to db"
      @io.each_line do | line |
        iso_date, temp, kilowatts = line.split( "," )
        logger.debug "Processing line #{line}"

        @set.samples << Sample.new( :sample_time => DateTime.parse( iso_date.strip ),
                             :temperature => temp.strip,
                             :generated_kilowatts => kilowatts.strip )
      end                    
      

      if @set.save
        flash[:notice] = "Uploaded #{@original_filename}"
      else
        render :action => "new" 
      end
      logger.debug "Finished writing file #{@original_filename} to db"
      
    rescue => e
      logger.error e.message
    end
  end

 
end
