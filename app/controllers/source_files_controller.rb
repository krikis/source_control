class SourceFilesController < ApplicationController

  before_filter :initialize_request

  def index
    if @folder
      @folders = @folder.children
      @source_files = @folder.source_files
    else
      @folders = Folder.find_roots
      @source_files = SourceFile.find_roots
    end
  end

  def show
    @source_file = SourceFile.find params[:id]
    redirect_to source_files_path unless @source_file
  end

  def create
    path = hash_for_source_files_path.merge({:folder_id => params[:folder_id]})
    if @person
      source_file = SourceFile.create params.merge(:last_update => Time.now)
      flash[:success] = "Source file \"#{source_file.name}\" added." if source_file.errors.blank?
      redirect_to path.merge({:selected_id => source_file.id})
    else
      redirect_to path
    end
  end

  def edit
    @source_file = SourceFile.find params[:id]
    if @source_file and @person and request.put? and
       (@source_file.lock.blank? or @source_file.lock == @person.id)
      @source_file.update_attributes :lock => @person.id,
                                     :locked_at => Time.now,
                                     :last_update => Time.now
    else
      redirect_to source_file_path(:id => params[:id])
    end
  end

  def update
    source_file = SourceFile.find params[:id]
    if source_file and @person
      source_file.update_attributes params[:source_file].merge(:last_update => Time.now, :lock => nil, :locked_at => nil)
      flash[:success] = "Source file \"#{source_file.name}\" updated." if source_file.errors.blank?
    end  
    redirect_to source_file_path(:id => params[:id])
  end
  
  def unlock
    source_file = SourceFile.find params[:id]
    if source_file and @person and @person == source_file.person
      source_file.update_attributes :lock => nil, 
                                    :locked_at => nil,
                                    :last_update => Time.now
    end                                
    redirect_to source_file_path(:id => params[:id])
  end

  def download
    if @person
      source_file = SourceFile.find params[:id]
      send_data source_file.code,
                :filename => source_file.name,
                :type => "text/plain"
      source_file.update_attributes :lock => @person.id,
                                    :locked_at => Time.now
    end
  end
  
  def destroy
    if @person
      source_file = SourceFile.find params[:id]
      source_file.destroy unless source_file.lock
    end
    redirect_to :back
  end

  private

  def initialize_request
    super
    @folder = Folder.find params[:folder_id]
  end

end
